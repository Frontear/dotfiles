package network

import (
	"fmt"
	"time"

	"github.com/AvengeMedia/danklinux/internal/errdefs"
	"github.com/godbus/dbus/v5"
)

func (b *IWDBackend) updateState() error {
	if b.devicePath == "" {
		return nil
	}

	obj := b.conn.Object(iwdBusName, b.devicePath)

	poweredVar, err := obj.GetProperty(iwdDeviceInterface + ".Powered")
	if err == nil {
		if powered, ok := poweredVar.Value().(bool); ok {
			b.stateMutex.Lock()
			b.state.WiFiEnabled = powered
			b.stateMutex.Unlock()
		}
	}

	if b.stationPath == "" {
		return nil
	}

	stationObj := b.conn.Object(iwdBusName, b.stationPath)

	stateVar, err := stationObj.GetProperty(iwdStationInterface + ".State")
	if err == nil {
		if state, ok := stateVar.Value().(string); ok {
			b.stateMutex.Lock()
			b.state.WiFiConnected = (state == "connected")
			if state == "connected" {
				b.state.NetworkStatus = StatusWiFi
			} else {
				b.state.NetworkStatus = StatusDisconnected
			}
			b.stateMutex.Unlock()
		}
	}

	connNetVar, err := stationObj.GetProperty(iwdStationInterface + ".ConnectedNetwork")
	if err == nil && connNetVar.Value() != nil {
		if netPath, ok := connNetVar.Value().(dbus.ObjectPath); ok && netPath != "/" {
			netObj := b.conn.Object(iwdBusName, netPath)

			nameVar, err := netObj.GetProperty(iwdNetworkInterface + ".Name")
			if err == nil {
				if name, ok := nameVar.Value().(string); ok {
					b.stateMutex.Lock()
					b.state.WiFiSSID = name
					b.stateMutex.Unlock()
				}
			}

			var orderedNetworks [][]dbus.Variant
			err = stationObj.Call(iwdStationInterface+".GetOrderedNetworks", 0).Store(&orderedNetworks)
			if err == nil {
				for _, netData := range orderedNetworks {
					if len(netData) < 2 {
						continue
					}
					currentNetPath, ok := netData[0].Value().(dbus.ObjectPath)
					if !ok || currentNetPath != netPath {
						continue
					}
					signalStrength, ok := netData[1].Value().(int16)
					if !ok {
						continue
					}
					signalDbm := signalStrength / 100
					signal := uint8(signalDbm + 100)
					if signalDbm > 0 {
						signal = 100
					} else if signalDbm < -100 {
						signal = 0
					}
					b.stateMutex.Lock()
					b.state.WiFiSignal = signal
					b.stateMutex.Unlock()
					break
				}
			}
		}
	}

	networks, err := b.updateWiFiNetworks()
	if err == nil {
		b.stateMutex.Lock()
		b.state.WiFiNetworks = networks
		b.stateMutex.Unlock()
	}

	return nil
}

func (b *IWDBackend) GetWiFiEnabled() (bool, error) {
	b.stateMutex.RLock()
	defer b.stateMutex.RUnlock()
	return b.state.WiFiEnabled, nil
}

func (b *IWDBackend) SetWiFiEnabled(enabled bool) error {
	if b.devicePath == "" {
		return fmt.Errorf("no WiFi device available")
	}

	obj := b.conn.Object(iwdBusName, b.devicePath)
	call := obj.Call(dbusPropertiesInterface+".Set", 0, iwdDeviceInterface, "Powered", dbus.MakeVariant(enabled))
	if call.Err != nil {
		return fmt.Errorf("failed to set WiFi enabled: %w", call.Err)
	}

	b.stateMutex.Lock()
	b.state.WiFiEnabled = enabled
	b.stateMutex.Unlock()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}

func (b *IWDBackend) ScanWiFi() error {
	if b.stationPath == "" {
		return fmt.Errorf("no WiFi device available")
	}

	obj := b.conn.Object(iwdBusName, b.stationPath)

	scanningVar, err := obj.GetProperty(iwdStationInterface + ".Scanning")
	if err != nil {
		return fmt.Errorf("failed to check scanning state: %w", err)
	}

	if scanning, ok := scanningVar.Value().(bool); ok && scanning {
		return fmt.Errorf("scan already in progress")
	}

	call := obj.Call(iwdStationInterface+".Scan", 0)
	if call.Err != nil {
		return fmt.Errorf("scan request failed: %w", call.Err)
	}

	return nil
}

func (b *IWDBackend) updateWiFiNetworks() ([]WiFiNetwork, error) {
	if b.stationPath == "" {
		return nil, fmt.Errorf("no WiFi device available")
	}

	obj := b.conn.Object(iwdBusName, b.stationPath)

	var orderedNetworks [][]dbus.Variant
	err := obj.Call(iwdStationInterface+".GetOrderedNetworks", 0).Store(&orderedNetworks)
	if err != nil {
		return nil, fmt.Errorf("failed to get networks: %w", err)
	}

	knownNetworks, err := b.getKnownNetworks()
	if err != nil {
		knownNetworks = make(map[string]bool)
	}

	autoconnectMap, err := b.getAutoconnectSettings()
	if err != nil {
		autoconnectMap = make(map[string]bool)
	}

	b.stateMutex.RLock()
	currentSSID := b.state.WiFiSSID
	wifiConnected := b.state.WiFiConnected
	b.stateMutex.RUnlock()

	networks := make([]WiFiNetwork, 0, len(orderedNetworks))
	for _, netData := range orderedNetworks {
		if len(netData) < 2 {
			continue
		}

		networkPath, ok := netData[0].Value().(dbus.ObjectPath)
		if !ok {
			continue
		}

		signalStrength, ok := netData[1].Value().(int16)
		if !ok {
			continue
		}

		netObj := b.conn.Object(iwdBusName, networkPath)

		nameVar, err := netObj.GetProperty(iwdNetworkInterface + ".Name")
		if err != nil {
			continue
		}
		name, ok := nameVar.Value().(string)
		if !ok {
			continue
		}

		typeVar, err := netObj.GetProperty(iwdNetworkInterface + ".Type")
		if err != nil {
			continue
		}
		netType, ok := typeVar.Value().(string)
		if !ok {
			continue
		}

		signalDbm := signalStrength / 100
		signal := uint8(signalDbm + 100)
		if signalDbm > 0 {
			signal = 100
		} else if signalDbm < -100 {
			signal = 0
		}

		secured := netType != "open"

		network := WiFiNetwork{
			SSID:        name,
			Signal:      signal,
			Secured:     secured,
			Connected:   wifiConnected && name == currentSSID,
			Saved:       knownNetworks[name],
			Autoconnect: autoconnectMap[name],
			Enterprise:  netType == "8021x",
		}

		networks = append(networks, network)
	}

	sortWiFiNetworks(networks)

	b.stateMutex.Lock()
	b.state.WiFiNetworks = networks
	b.stateMutex.Unlock()

	now := time.Now()
	b.recentScansMu.Lock()
	for _, net := range networks {
		b.recentScans[net.SSID] = now
	}
	b.recentScansMu.Unlock()

	return networks, nil
}

func (b *IWDBackend) getKnownNetworks() (map[string]bool, error) {
	obj := b.conn.Object(iwdBusName, iwdObjectPath)

	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := obj.Call(dbusObjectManager+".GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return nil, err
	}

	known := make(map[string]bool)
	for _, interfaces := range objects {
		if knownProps, ok := interfaces[iwdKnownNetworkInterface]; ok {
			if nameVar, ok := knownProps["Name"]; ok {
				if name, ok := nameVar.Value().(string); ok {
					known[name] = true
				}
			}
		}
	}

	return known, nil
}

func (b *IWDBackend) getAutoconnectSettings() (map[string]bool, error) {
	obj := b.conn.Object(iwdBusName, iwdObjectPath)

	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := obj.Call(dbusObjectManager+".GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return nil, err
	}

	autoconnectMap := make(map[string]bool)
	for _, interfaces := range objects {
		if knownProps, ok := interfaces[iwdKnownNetworkInterface]; ok {
			if nameVar, ok := knownProps["Name"]; ok {
				if name, ok := nameVar.Value().(string); ok {
					autoconnect := true
					if acVar, ok := knownProps["AutoConnect"]; ok {
						if ac, ok := acVar.Value().(bool); ok {
							autoconnect = ac
						}
					}
					autoconnectMap[name] = autoconnect
				}
			}
		}
	}

	return autoconnectMap, nil
}

func (b *IWDBackend) GetWiFiNetworkDetails(ssid string) (*NetworkInfoResponse, error) {
	b.stateMutex.RLock()
	networks := b.state.WiFiNetworks
	b.stateMutex.RUnlock()

	var found *WiFiNetwork
	for i := range networks {
		if networks[i].SSID == ssid {
			found = &networks[i]
			break
		}
	}

	if found == nil {
		return nil, fmt.Errorf("network not found: %s", ssid)
	}

	return &NetworkInfoResponse{
		SSID:  ssid,
		Bands: []WiFiNetwork{*found},
	}, nil
}

func (b *IWDBackend) setConnectError(code string) {
	b.stateMutex.Lock()
	b.state.IsConnecting = false
	b.state.ConnectingSSID = ""
	b.state.LastError = code
	b.stateMutex.Unlock()
}

func (b *IWDBackend) seenInRecentScan(ssid string) bool {
	b.recentScansMu.Lock()
	defer b.recentScansMu.Unlock()
	lastSeen, ok := b.recentScans[ssid]
	return ok && time.Since(lastSeen) < 30*time.Second
}

func (b *IWDBackend) classifyAttempt(att *connectAttempt) string {
	att.mu.Lock()
	defer att.mu.Unlock()

	if att.sawPromptRetry {
		return errdefs.ErrBadCredentials
	}

	if !att.connectedAt.IsZero() && !att.sawIPConfig {
		connDuration := time.Since(att.connectedAt)
		if connDuration > 500*time.Millisecond && connDuration < 3*time.Second {
			return errdefs.ErrBadCredentials
		}
	}

	if (att.sawAuthish || !att.connectedAt.IsZero()) && !att.sawIPConfig {
		if time.Since(att.start) > 12*time.Second {
			return errdefs.ErrDhcpTimeout
		}
	}

	if !att.sawAuthish && att.connectedAt.IsZero() {
		if !b.seenInRecentScan(att.ssid) {
			return errdefs.ErrNoSuchSSID
		}
		return errdefs.ErrAssocTimeout
	}

	return errdefs.ErrAssocTimeout
}

func (b *IWDBackend) finalizeAttempt(att *connectAttempt, code string) {
	att.mu.Lock()
	if att.finalized {
		att.mu.Unlock()
		return
	}
	att.finalized = true
	att.mu.Unlock()

	b.stateMutex.Lock()
	b.state.IsConnecting = false
	b.state.ConnectingSSID = ""
	b.state.LastError = code
	b.stateMutex.Unlock()

	b.updateState()

	if b.onStateChange != nil {
		b.onStateChange()
	}
}

func (b *IWDBackend) startAttemptWatchdog(att *connectAttempt) {
	b.sigWG.Add(1)
	go func() {
		defer b.sigWG.Done()

		ticker := time.NewTicker(250 * time.Millisecond)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				att.mu.Lock()
				finalized := att.finalized
				att.mu.Unlock()

				if finalized || time.Now().After(att.deadline) {
					if !finalized {
						b.finalizeAttempt(att, b.classifyAttempt(att))
					}
					return
				}

				station := b.conn.Object(iwdBusName, b.stationPath)
				stVar, err := station.GetProperty(iwdStationInterface + ".State")
				if err != nil {
					continue
				}
				state, _ := stVar.Value().(string)

				cnVar, err := station.GetProperty(iwdStationInterface + ".ConnectedNetwork")
				if err != nil {
					continue
				}
				var connPath dbus.ObjectPath
				if cnVar.Value() != nil {
					connPath, _ = cnVar.Value().(dbus.ObjectPath)
				}

				att.mu.Lock()
				if connPath == att.netPath && state == "connected" && att.connectedAt.IsZero() {
					att.connectedAt = time.Now()
				}
				if state == "configuring" {
					att.sawIPConfig = true
				}
				att.mu.Unlock()

			case <-b.stopChan:
				return
			}
		}
	}()
}

func (b *IWDBackend) mapIwdDBusError(name string) string {
	switch name {
	case "net.connman.iwd.Error.AlreadyConnected":
		return errdefs.ErrAlreadyConnected
	case "net.connman.iwd.Error.AuthenticationFailed",
		"net.connman.iwd.Error.InvalidKey",
		"net.connman.iwd.Error.IncorrectPassphrase":
		return errdefs.ErrBadCredentials
	case "net.connman.iwd.Error.NotFound":
		return errdefs.ErrNoSuchSSID
	case "net.connman.iwd.Error.NotSupported":
		return errdefs.ErrConnectionFailed
	case "net.connman.iwd.Agent.Error.Canceled":
		return errdefs.ErrUserCanceled
	default:
		return errdefs.ErrConnectionFailed
	}
}

func (b *IWDBackend) ConnectWiFi(req ConnectionRequest) error {
	if b.stationPath == "" {
		b.setConnectError(errdefs.ErrWifiDisabled)
		if b.onStateChange != nil {
			b.onStateChange()
		}
		return fmt.Errorf("no WiFi device available")
	}

	networkPath, err := b.findNetworkPath(req.SSID)
	if err != nil {
		b.setConnectError(errdefs.ErrNoSuchSSID)
		if b.onStateChange != nil {
			b.onStateChange()
		}
		return fmt.Errorf("network not found: %w", err)
	}

	att := &connectAttempt{
		ssid:     req.SSID,
		netPath:  networkPath,
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	b.attemptMutex.Lock()
	b.curAttempt = att
	b.attemptMutex.Unlock()

	b.stateMutex.Lock()
	b.state.IsConnecting = true
	b.state.ConnectingSSID = req.SSID
	b.state.LastError = ""
	b.stateMutex.Unlock()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	netObj := b.conn.Object(iwdBusName, networkPath)
	go func() {
		call := netObj.Call(iwdNetworkInterface+".Connect", 0)
		if call.Err != nil {
			var code string
			if dbusErr, ok := call.Err.(dbus.Error); ok {
				code = b.mapIwdDBusError(dbusErr.Name)
			} else if dbusErrPtr, ok := call.Err.(*dbus.Error); ok {
				code = b.mapIwdDBusError(dbusErrPtr.Name)
			} else {
				code = errdefs.ErrConnectionFailed
			}

			att.mu.Lock()
			if att.sawPromptRetry {
				code = errdefs.ErrBadCredentials
			}
			att.mu.Unlock()

			b.finalizeAttempt(att, code)
			return
		}

		b.startAttemptWatchdog(att)
	}()

	return nil
}

func (b *IWDBackend) findNetworkPath(ssid string) (dbus.ObjectPath, error) {
	obj := b.conn.Object(iwdBusName, iwdObjectPath)

	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := obj.Call(dbusObjectManager+".GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return "", err
	}

	for path, interfaces := range objects {
		if netProps, ok := interfaces[iwdNetworkInterface]; ok {
			if nameVar, ok := netProps["Name"]; ok {
				if name, ok := nameVar.Value().(string); ok && name == ssid {
					return path, nil
				}
			}
		}
	}

	return "", fmt.Errorf("network not found")
}

func (b *IWDBackend) DisconnectWiFi() error {
	if b.stationPath == "" {
		return fmt.Errorf("no WiFi device available")
	}

	obj := b.conn.Object(iwdBusName, b.stationPath)
	call := obj.Call(iwdStationInterface+".Disconnect", 0)
	if call.Err != nil {
		return fmt.Errorf("failed to disconnect: %w", call.Err)
	}

	b.updateState()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}

func (b *IWDBackend) ForgetWiFiNetwork(ssid string) error {
	b.stateMutex.RLock()
	currentSSID := b.state.WiFiSSID
	isConnected := b.state.WiFiConnected
	b.stateMutex.RUnlock()

	obj := b.conn.Object(iwdBusName, iwdObjectPath)

	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := obj.Call(dbusObjectManager+".GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return err
	}

	for path, interfaces := range objects {
		if knownProps, ok := interfaces[iwdKnownNetworkInterface]; ok {
			if nameVar, ok := knownProps["Name"]; ok {
				if name, ok := nameVar.Value().(string); ok && name == ssid {
					knownObj := b.conn.Object(iwdBusName, path)
					call := knownObj.Call(iwdKnownNetworkInterface+".Forget", 0)
					if call.Err != nil {
						return fmt.Errorf("failed to forget network: %w", call.Err)
					}

					if isConnected && currentSSID == ssid {
						b.stateMutex.Lock()
						b.state.WiFiConnected = false
						b.state.WiFiSSID = ""
						b.state.WiFiSignal = 0
						b.state.WiFiIP = ""
						b.state.NetworkStatus = StatusDisconnected
						b.stateMutex.Unlock()
					}

					if b.onStateChange != nil {
						b.onStateChange()
					}

					return nil
				}
			}
		}
	}

	return fmt.Errorf("network not found")
}

func (b *IWDBackend) SetWiFiAutoconnect(ssid string, autoconnect bool) error {
	obj := b.conn.Object(iwdBusName, iwdObjectPath)

	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := obj.Call(dbusObjectManager+".GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return err
	}

	for path, interfaces := range objects {
		if knownProps, ok := interfaces[iwdKnownNetworkInterface]; ok {
			if nameVar, ok := knownProps["Name"]; ok {
				if name, ok := nameVar.Value().(string); ok && name == ssid {
					knownObj := b.conn.Object(iwdBusName, path)
					call := knownObj.Call(dbusPropertiesInterface+".Set", 0, iwdKnownNetworkInterface, "AutoConnect", dbus.MakeVariant(autoconnect))
					if call.Err != nil {
						return fmt.Errorf("failed to set autoconnect: %w", call.Err)
					}

					b.updateState()

					if b.onStateChange != nil {
						b.onStateChange()
					}

					return nil
				}
			}
		}
	}

	return fmt.Errorf("network not found")
}
