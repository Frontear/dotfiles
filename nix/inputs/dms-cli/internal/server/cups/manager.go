package cups

import (
	"fmt"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/AvengeMedia/danklinux/pkg/ipp"
)

func NewManager() (*Manager, error) {
	host := os.Getenv("DMS_IPP_HOST")
	if host == "" {
		host = "localhost"
	}

	portStr := os.Getenv("DMS_IPP_PORT")
	port := 631
	if portStr != "" {
		if p, err := strconv.Atoi(portStr); err == nil {
			port = p
		}
	}

	username := os.Getenv("DMS_IPP_USERNAME")
	password := os.Getenv("DMS_IPP_PASSWORD")

	client := ipp.NewCUPSClient(host, port, username, password, false)
	baseURL := fmt.Sprintf("http://%s:%d", host, port)

	m := &Manager{
		state: &CUPSState{
			Printers: make(map[string]*Printer),
		},
		client:      client,
		baseURL:     baseURL,
		stateMutex:  sync.RWMutex{},
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
		subscribers: make(map[string]chan CUPSState),
		subMutex:    sync.RWMutex{},
	}

	if err := m.updateState(); err != nil {
		return nil, err
	}

	if isLocalCUPS(host) {
		m.subscription = NewDBusSubscriptionManager(client, baseURL)
		log.Infof("[CUPS] Using D-Bus notifications for local CUPS")
	} else {
		m.subscription = NewSubscriptionManager(client, baseURL)
		log.Infof("[CUPS] Using IPPGET notifications for remote CUPS")
	}

	m.notifierWg.Add(1)
	go m.notifier()

	return m, nil
}

func isLocalCUPS(host string) bool {
	switch host {
	case "localhost", "127.0.0.1", "::1", "":
		return true
	}
	return false
}

func (m *Manager) eventHandler() {
	defer m.eventWG.Done()

	if m.subscription == nil {
		return
	}

	for {
		select {
		case <-m.stopChan:
			return
		case event, ok := <-m.subscription.Events():
			if !ok {
				return
			}
			log.Debugf("[CUPS] Received event: %s (printer: %s, job: %d)",
				event.EventName, event.PrinterName, event.JobID)

			if err := m.updateState(); err != nil {
				log.Warnf("[CUPS] Failed to update state after event: %v", err)
			} else {
				m.notifySubscribers()
			}
		}
	}
}

func (m *Manager) updateState() error {
	printers, err := m.GetPrinters()
	if err != nil {
		return err
	}

	printerMap := make(map[string]*Printer, len(printers))
	for _, printer := range printers {
		jobs, err := m.GetJobs(printer.Name, "not-completed")
		if err != nil {
			return err
		}

		printer.Jobs = jobs
		printerMap[printer.Name] = &printer
	}

	m.stateMutex.Lock()
	m.state.Printers = printerMap
	m.stateMutex.Unlock()

	return nil
}

func (m *Manager) notifier() {
	defer m.notifierWg.Done()
	const minGap = 100 * time.Millisecond
	timer := time.NewTimer(minGap)
	timer.Stop()
	var pending bool
	for {
		select {
		case <-m.stopChan:
			timer.Stop()
			return
		case <-m.dirty:
			if pending {
				continue
			}
			pending = true
			timer.Reset(minGap)
		case <-timer.C:
			if !pending {
				continue
			}
			m.subMutex.RLock()
			if len(m.subscribers) == 0 {
				m.subMutex.RUnlock()
				pending = false
				continue
			}

			currentState := m.snapshotState()

			if m.lastNotifiedState != nil && !stateChanged(m.lastNotifiedState, &currentState) {
				m.subMutex.RUnlock()
				pending = false
				continue
			}

			for _, ch := range m.subscribers {
				select {
				case ch <- currentState:
				default:
				}
			}
			m.subMutex.RUnlock()

			stateCopy := currentState
			m.lastNotifiedState = &stateCopy
			pending = false
		}
	}
}

func (m *Manager) notifySubscribers() {
	select {
	case m.dirty <- struct{}{}:
	default:
	}
}

func (m *Manager) GetState() CUPSState {
	return m.snapshotState()
}

func (m *Manager) snapshotState() CUPSState {
	m.stateMutex.RLock()
	defer m.stateMutex.RUnlock()

	s := CUPSState{
		Printers: make(map[string]*Printer, len(m.state.Printers)),
	}
	for name, printer := range m.state.Printers {
		printerCopy := *printer
		s.Printers[name] = &printerCopy
	}
	return s
}

func (m *Manager) Subscribe(id string) chan CUPSState {
	ch := make(chan CUPSState, 64)
	m.subMutex.Lock()
	wasEmpty := len(m.subscribers) == 0
	m.subscribers[id] = ch
	m.subMutex.Unlock()

	if wasEmpty && m.subscription != nil {
		if err := m.subscription.Start(); err != nil {
			log.Warnf("[CUPS] Failed to start subscription manager: %v", err)
		} else {
			m.eventWG.Add(1)
			go m.eventHandler()
		}
	}

	return ch
}

func (m *Manager) Unsubscribe(id string) {
	m.subMutex.Lock()
	if ch, ok := m.subscribers[id]; ok {
		close(ch)
		delete(m.subscribers, id)
	}
	isEmpty := len(m.subscribers) == 0
	m.subMutex.Unlock()

	if isEmpty && m.subscription != nil {
		m.subscription.Stop()
		m.eventWG.Wait()
	}
}

func (m *Manager) Close() {
	close(m.stopChan)

	if m.subscription != nil {
		m.subscription.Stop()
	}

	m.eventWG.Wait()
	m.notifierWg.Wait()

	m.subMutex.Lock()
	for _, ch := range m.subscribers {
		close(ch)
	}
	m.subscribers = make(map[string]chan CUPSState)
	m.subMutex.Unlock()
}

func stateChanged(old, new *CUPSState) bool {
	if len(old.Printers) != len(new.Printers) {
		return true
	}
	for name, oldPrinter := range old.Printers {
		newPrinter, exists := new.Printers[name]
		if !exists {
			return true
		}
		if oldPrinter.State != newPrinter.State ||
			oldPrinter.StateReason != newPrinter.StateReason ||
			len(oldPrinter.Jobs) != len(newPrinter.Jobs) {
			return true
		}
	}
	return false
}

func parsePrinterState(attrs ipp.Attributes) string {
	if stateAttr, ok := attrs[ipp.AttributePrinterState]; ok && len(stateAttr) > 0 {
		if state, ok := stateAttr[0].Value.(int); ok {
			switch state {
			case 3:
				return "idle"
			case 4:
				return "processing"
			case 5:
				return "stopped"
			default:
				return fmt.Sprintf("%d", state)
			}
		}
	}
	return "unknown"
}

func parseJobState(attrs ipp.Attributes) string {
	if stateAttr, ok := attrs[ipp.AttributeJobState]; ok && len(stateAttr) > 0 {
		if state, ok := stateAttr[0].Value.(int); ok {
			switch state {
			case 3:
				return "pending"
			case 4:
				return "pending-held"
			case 5:
				return "processing"
			case 6:
				return "processing-stopped"
			case 7:
				return "canceled"
			case 8:
				return "aborted"
			case 9:
				return "completed"
			default:
				return fmt.Sprintf("%d", state)
			}
		}
	}
	return "unknown"
}

func getStringAttr(attrs ipp.Attributes, key string) string {
	if attr, ok := attrs[key]; ok && len(attr) > 0 {
		if val, ok := attr[0].Value.(string); ok {
			return val
		}
		return fmt.Sprintf("%v", attr[0].Value)
	}
	return ""
}

func getIntAttr(attrs ipp.Attributes, key string) int {
	if attr, ok := attrs[key]; ok && len(attr) > 0 {
		if val, ok := attr[0].Value.(int); ok {
			return val
		}
	}
	return 0
}

func getBoolAttr(attrs ipp.Attributes, key string) bool {
	if attr, ok := attrs[key]; ok && len(attr) > 0 {
		if val, ok := attr[0].Value.(bool); ok {
			return val
		}
	}
	return false
}
