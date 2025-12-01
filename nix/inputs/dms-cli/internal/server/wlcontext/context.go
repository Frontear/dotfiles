package wlcontext

import (
	"fmt"
	"sync"

	"github.com/AvengeMedia/danklinux/internal/errdefs"
	"github.com/AvengeMedia/danklinux/internal/log"
	wlclient "github.com/yaslama/go-wayland/wayland/client"
)

type SharedContext struct {
	display  *wlclient.Display
	stopChan chan struct{}
	wg       sync.WaitGroup
	mu       sync.Mutex
	started  bool
}

func New() (*SharedContext, error) {
	display, err := wlclient.Connect("")
	if err != nil {
		return nil, fmt.Errorf("%w: %v", errdefs.ErrNoWaylandDisplay, err)
	}

	sc := &SharedContext{
		display:  display,
		stopChan: make(chan struct{}),
		started:  false,
	}

	return sc, nil
}

func (sc *SharedContext) Start() {
	sc.mu.Lock()
	defer sc.mu.Unlock()

	if sc.started {
		return
	}

	sc.started = true
	sc.wg.Add(1)
	go sc.eventDispatcher()
}

func (sc *SharedContext) Display() *wlclient.Display {
	return sc.display
}

func (sc *SharedContext) eventDispatcher() {
	defer sc.wg.Done()
	ctx := sc.display.Context()

	for {
		select {
		case <-sc.stopChan:
			return
		default:
			if err := ctx.Dispatch(); err != nil {
				log.Errorf("Wayland connection error: %v", err)
				return
			}
		}
	}
}

func (sc *SharedContext) Close() {
	close(sc.stopChan)
	sc.wg.Wait()

	if sc.display != nil {
		sc.display.Context().Close()
	}
}
