package network

import (
	"bytes"
	"fmt"
	"sort"

	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/Wifx/gonetworkmanager/v2"
)

func (b *NetworkManagerBackend) GetWiFiEnabled() (bool, error) {
	nm := b.nmConn.(gonetworkmanager.NetworkManager)
	return nm.GetPropertyWirelessEnabled()
}

func (b *NetworkManagerBackend) SetWiFiEnabled(enabled bool) error {
	nm := b.nmConn.(gonetworkmanager.NetworkManager)
	err := nm.SetPropertyWirelessEnabled(enabled)
	if err != nil {
		return fmt.Errorf("failed to set WiFi enabled: %w", err)
	}

	b.stateMutex.Lock()
	b.state.WiFiEnabled = enabled
	b.stateMutex.Unlock()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}

func (b *NetworkManagerBackend) ScanWiFi() error {
	if b.wifiDevice == nil {
		return fmt.Errorf("no WiFi device available")
	}

	b.stateMutex.RLock()
	enabled := b.state.WiFiEnabled
	b.stateMutex.RUnlock()

	if !enabled {
		return fmt.Errorf("WiFi is disabled")
	}

	if err := b.ensureWiFiDevice(); err != nil {
		return err
	}

	w := b.wifiDev.(gonetworkmanager.DeviceWireless)
	err := w.RequestScan()
	if err != nil {
		return fmt.Errorf("scan request failed: %w", err)
	}

	_, err = b.updateWiFiNetworks()
	return err
}

func (b *NetworkManagerBackend) GetWiFiNetworkDetails(ssid string) (*NetworkInfoResponse, error) {
	if b.wifiDevice == nil {
		return nil, fmt.Errorf("no WiFi device available")
	}

	if err := b.ensureWiFiDevice(); err != nil {
		return nil, err
	}
	wifiDev := b.wifiDev

	w := wifiDev.(gonetworkmanager.DeviceWireless)
	apPaths, err := w.GetAccessPoints()
	if err != nil {
		return nil, fmt.Errorf("failed to get access points: %w", err)
	}

	s := b.settings
	if s == nil {
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return nil, fmt.Errorf("failed to get settings: %w", err)
		}
		b.settings = s
	}

	settingsMgr := s.(gonetworkmanager.Settings)
	connections, err := settingsMgr.ListConnections()
	if err != nil {
		return nil, fmt.Errorf("failed to get connections: %w", err)
	}

	savedSSIDs := make(map[string]bool)
	autoconnectMap := make(map[string]bool)
	for _, conn := range connections {
		connSettings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		if connMeta, ok := connSettings["connection"]; ok {
			if connType, ok := connMeta["type"].(string); ok && connType == "802-11-wireless" {
				if wifiSettings, ok := connSettings["802-11-wireless"]; ok {
					if ssidBytes, ok := wifiSettings["ssid"].([]byte); ok {
						savedSSID := string(ssidBytes)
						savedSSIDs[savedSSID] = true
						autoconnect := true
						if ac, ok := connMeta["autoconnect"].(bool); ok {
							autoconnect = ac
						}
						autoconnectMap[savedSSID] = autoconnect
					}
				}
			}
		}
	}

	b.stateMutex.RLock()
	currentSSID := b.state.WiFiSSID
	currentBSSID := b.state.WiFiBSSID
	b.stateMutex.RUnlock()

	var bands []WiFiNetwork

	for _, ap := range apPaths {
		apSSID, err := ap.GetPropertySSID()
		if err != nil || apSSID != ssid {
			continue
		}

		strength, _ := ap.GetPropertyStrength()
		flags, _ := ap.GetPropertyFlags()
		wpaFlags, _ := ap.GetPropertyWPAFlags()
		rsnFlags, _ := ap.GetPropertyRSNFlags()
		freq, _ := ap.GetPropertyFrequency()
		maxBitrate, _ := ap.GetPropertyMaxBitrate()
		bssid, _ := ap.GetPropertyHWAddress()
		mode, _ := ap.GetPropertyMode()

		secured := flags != uint32(gonetworkmanager.Nm80211APFlagsNone) ||
			wpaFlags != uint32(gonetworkmanager.Nm80211APSecNone) ||
			rsnFlags != uint32(gonetworkmanager.Nm80211APSecNone)

		enterprise := (rsnFlags&uint32(gonetworkmanager.Nm80211APSecKeyMgmt8021X) != 0) ||
			(wpaFlags&uint32(gonetworkmanager.Nm80211APSecKeyMgmt8021X) != 0)

		var modeStr string
		switch mode {
		case gonetworkmanager.Nm80211ModeAdhoc:
			modeStr = "adhoc"
		case gonetworkmanager.Nm80211ModeInfra:
			modeStr = "infrastructure"
		case gonetworkmanager.Nm80211ModeAp:
			modeStr = "ap"
		default:
			modeStr = "unknown"
		}

		channel := frequencyToChannel(freq)

		network := WiFiNetwork{
			SSID:        ssid,
			BSSID:       bssid,
			Signal:      strength,
			Secured:     secured,
			Enterprise:  enterprise,
			Connected:   ssid == currentSSID && bssid == currentBSSID,
			Saved:       savedSSIDs[ssid],
			Autoconnect: autoconnectMap[ssid],
			Frequency:   freq,
			Mode:        modeStr,
			Rate:        maxBitrate / 1000,
			Channel:     channel,
		}

		bands = append(bands, network)
	}

	if len(bands) == 0 {
		return nil, fmt.Errorf("network not found: %s", ssid)
	}

	sort.Slice(bands, func(i, j int) bool {
		if bands[i].Connected && !bands[j].Connected {
			return true
		}
		if !bands[i].Connected && bands[j].Connected {
			return false
		}
		return bands[i].Signal > bands[j].Signal
	})

	return &NetworkInfoResponse{
		SSID:  ssid,
		Bands: bands,
	}, nil
}

func (b *NetworkManagerBackend) ConnectWiFi(req ConnectionRequest) error {
	if b.wifiDevice == nil {
		return fmt.Errorf("no WiFi device available")
	}

	b.stateMutex.RLock()
	alreadyConnected := b.state.WiFiConnected && b.state.WiFiSSID == req.SSID
	b.stateMutex.RUnlock()

	if alreadyConnected && !req.Interactive {
		return nil
	}

	b.stateMutex.Lock()
	b.state.IsConnecting = true
	b.state.ConnectingSSID = req.SSID
	b.state.LastError = ""
	b.stateMutex.Unlock()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	nm := b.nmConn.(gonetworkmanager.NetworkManager)

	existingConn, err := b.findConnection(req.SSID)
	if err == nil && existingConn != nil {
		dev := b.wifiDevice.(gonetworkmanager.Device)

		_, err := nm.ActivateConnection(existingConn, dev, nil)
		if err != nil {
			log.Warnf("[ConnectWiFi] Failed to activate existing connection: %v", err)
			b.stateMutex.Lock()
			b.state.IsConnecting = false
			b.state.ConnectingSSID = ""
			b.state.LastError = fmt.Sprintf("failed to activate connection: %v", err)
			b.stateMutex.Unlock()
			if b.onStateChange != nil {
				b.onStateChange()
			}
			return fmt.Errorf("failed to activate connection: %w", err)
		}

		return nil
	}

	if err := b.createAndConnectWiFi(req); err != nil {
		log.Warnf("[ConnectWiFi] Failed to create and connect: %v", err)
		b.stateMutex.Lock()
		b.state.IsConnecting = false
		b.state.ConnectingSSID = ""
		b.state.LastError = err.Error()
		b.stateMutex.Unlock()
		if b.onStateChange != nil {
			b.onStateChange()
		}
		return err
	}

	return nil
}

func (b *NetworkManagerBackend) DisconnectWiFi() error {
	if b.wifiDevice == nil {
		return fmt.Errorf("no WiFi device available")
	}

	dev := b.wifiDevice.(gonetworkmanager.Device)

	err := dev.Disconnect()
	if err != nil {
		return fmt.Errorf("failed to disconnect: %w", err)
	}

	b.updateWiFiState()
	b.updatePrimaryConnection()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}

func (b *NetworkManagerBackend) ForgetWiFiNetwork(ssid string) error {
	conn, err := b.findConnection(ssid)
	if err != nil {
		return fmt.Errorf("connection not found: %w", err)
	}

	b.stateMutex.RLock()
	currentSSID := b.state.WiFiSSID
	isConnected := b.state.WiFiConnected
	b.stateMutex.RUnlock()

	err = conn.Delete()
	if err != nil {
		return fmt.Errorf("failed to delete connection: %w", err)
	}

	if isConnected && currentSSID == ssid {
		b.stateMutex.Lock()
		b.state.WiFiConnected = false
		b.state.WiFiSSID = ""
		b.state.WiFiBSSID = ""
		b.state.WiFiSignal = 0
		b.state.WiFiIP = ""
		b.state.NetworkStatus = StatusDisconnected
		b.stateMutex.Unlock()
	}

	b.updateWiFiNetworks()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}

func (b *NetworkManagerBackend) IsConnectingTo(ssid string) bool {
	b.stateMutex.RLock()
	defer b.stateMutex.RUnlock()
	return b.state.IsConnecting && b.state.ConnectingSSID == ssid
}

func (b *NetworkManagerBackend) updateWiFiNetworks() ([]WiFiNetwork, error) {
	if b.wifiDevice == nil {
		return nil, fmt.Errorf("no WiFi device available")
	}

	if err := b.ensureWiFiDevice(); err != nil {
		return nil, err
	}
	wifiDev := b.wifiDev

	w := wifiDev.(gonetworkmanager.DeviceWireless)
	apPaths, err := w.GetAccessPoints()
	if err != nil {
		return nil, fmt.Errorf("failed to get access points: %w", err)
	}

	s := b.settings
	if s == nil {
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return nil, fmt.Errorf("failed to get settings: %w", err)
		}
		b.settings = s
	}

	settingsMgr := s.(gonetworkmanager.Settings)
	connections, err := settingsMgr.ListConnections()
	if err != nil {
		return nil, fmt.Errorf("failed to get connections: %w", err)
	}

	savedSSIDs := make(map[string]bool)
	autoconnectMap := make(map[string]bool)
	for _, conn := range connections {
		connSettings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		if connMeta, ok := connSettings["connection"]; ok {
			if connType, ok := connMeta["type"].(string); ok && connType == "802-11-wireless" {
				if wifiSettings, ok := connSettings["802-11-wireless"]; ok {
					if ssidBytes, ok := wifiSettings["ssid"].([]byte); ok {
						ssid := string(ssidBytes)
						savedSSIDs[ssid] = true
						autoconnect := true
						if ac, ok := connMeta["autoconnect"].(bool); ok {
							autoconnect = ac
						}
						autoconnectMap[ssid] = autoconnect
					}
				}
			}
		}
	}

	b.stateMutex.RLock()
	currentSSID := b.state.WiFiSSID
	b.stateMutex.RUnlock()

	seenSSIDs := make(map[string]*WiFiNetwork)
	networks := []WiFiNetwork{}

	for _, ap := range apPaths {
		ssid, err := ap.GetPropertySSID()
		if err != nil || ssid == "" {
			continue
		}

		if existing, exists := seenSSIDs[ssid]; exists {
			strength, _ := ap.GetPropertyStrength()
			if strength > existing.Signal {
				existing.Signal = strength
				freq, _ := ap.GetPropertyFrequency()
				existing.Frequency = freq
				bssid, _ := ap.GetPropertyHWAddress()
				existing.BSSID = bssid
			}
			continue
		}

		strength, _ := ap.GetPropertyStrength()
		flags, _ := ap.GetPropertyFlags()
		wpaFlags, _ := ap.GetPropertyWPAFlags()
		rsnFlags, _ := ap.GetPropertyRSNFlags()
		freq, _ := ap.GetPropertyFrequency()
		maxBitrate, _ := ap.GetPropertyMaxBitrate()
		bssid, _ := ap.GetPropertyHWAddress()
		mode, _ := ap.GetPropertyMode()

		secured := flags != uint32(gonetworkmanager.Nm80211APFlagsNone) ||
			wpaFlags != uint32(gonetworkmanager.Nm80211APSecNone) ||
			rsnFlags != uint32(gonetworkmanager.Nm80211APSecNone)

		enterprise := (rsnFlags&uint32(gonetworkmanager.Nm80211APSecKeyMgmt8021X) != 0) ||
			(wpaFlags&uint32(gonetworkmanager.Nm80211APSecKeyMgmt8021X) != 0)

		var modeStr string
		switch mode {
		case gonetworkmanager.Nm80211ModeAdhoc:
			modeStr = "adhoc"
		case gonetworkmanager.Nm80211ModeInfra:
			modeStr = "infrastructure"
		case gonetworkmanager.Nm80211ModeAp:
			modeStr = "ap"
		default:
			modeStr = "unknown"
		}

		channel := frequencyToChannel(freq)

		network := WiFiNetwork{
			SSID:        ssid,
			BSSID:       bssid,
			Signal:      strength,
			Secured:     secured,
			Enterprise:  enterprise,
			Connected:   ssid == currentSSID,
			Saved:       savedSSIDs[ssid],
			Autoconnect: autoconnectMap[ssid],
			Frequency:   freq,
			Mode:        modeStr,
			Rate:        maxBitrate / 1000,
			Channel:     channel,
		}

		seenSSIDs[ssid] = &network
		networks = append(networks, network)
	}

	sortWiFiNetworks(networks)

	b.stateMutex.Lock()
	b.state.WiFiNetworks = networks
	b.stateMutex.Unlock()

	return networks, nil
}

func (b *NetworkManagerBackend) findConnection(ssid string) (gonetworkmanager.Connection, error) {
	s := b.settings
	if s == nil {
		var err error
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return nil, err
		}
		b.settings = s
	}

	settings := s.(gonetworkmanager.Settings)
	connections, err := settings.ListConnections()
	if err != nil {
		return nil, err
	}

	ssidBytes := []byte(ssid)
	for _, conn := range connections {
		connSettings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		if connMeta, ok := connSettings["connection"]; ok {
			if connType, ok := connMeta["type"].(string); ok && connType == "802-11-wireless" {
				if wifiSettings, ok := connSettings["802-11-wireless"]; ok {
					if candidateSSID, ok := wifiSettings["ssid"].([]byte); ok {
						if bytes.Equal(candidateSSID, ssidBytes) {
							return conn, nil
						}
					}
				}
			}
		}
	}

	return nil, fmt.Errorf("connection not found")
}

func (b *NetworkManagerBackend) createAndConnectWiFi(req ConnectionRequest) error {
	if b.wifiDevice == nil {
		return fmt.Errorf("no WiFi device available")
	}

	nm := b.nmConn.(gonetworkmanager.NetworkManager)
	dev := b.wifiDevice.(gonetworkmanager.Device)

	if err := b.ensureWiFiDevice(); err != nil {
		return err
	}
	wifiDev := b.wifiDev

	w := wifiDev.(gonetworkmanager.DeviceWireless)
	apPaths, err := w.GetAccessPoints()
	if err != nil {
		return fmt.Errorf("failed to get access points: %w", err)
	}

	var targetAP gonetworkmanager.AccessPoint
	for _, ap := range apPaths {
		ssid, err := ap.GetPropertySSID()
		if err != nil || ssid != req.SSID {
			continue
		}
		targetAP = ap
		break
	}

	if targetAP == nil {
		return fmt.Errorf("access point not found: %s", req.SSID)
	}

	flags, _ := targetAP.GetPropertyFlags()
	wpaFlags, _ := targetAP.GetPropertyWPAFlags()
	rsnFlags, _ := targetAP.GetPropertyRSNFlags()

	const KeyMgmt8021x = uint32(512)
	const KeyMgmtPsk = uint32(256)
	const KeyMgmtSae = uint32(1024)

	isEnterprise := (wpaFlags&KeyMgmt8021x) != 0 || (rsnFlags&KeyMgmt8021x) != 0
	isPsk := (wpaFlags&KeyMgmtPsk) != 0 || (rsnFlags&KeyMgmtPsk) != 0
	isSae := (wpaFlags&KeyMgmtSae) != 0 || (rsnFlags&KeyMgmtSae) != 0

	secured := flags != uint32(gonetworkmanager.Nm80211APFlagsNone) ||
		wpaFlags != uint32(gonetworkmanager.Nm80211APSecNone) ||
		rsnFlags != uint32(gonetworkmanager.Nm80211APSecNone)

	if isEnterprise {
		log.Infof("[createAndConnectWiFi] Enterprise network detected (802.1x) - SSID: %s, interactive: %v",
			req.SSID, req.Interactive)
	}

	settings := make(map[string]map[string]interface{})

	settings["connection"] = map[string]interface{}{
		"id":          req.SSID,
		"type":        "802-11-wireless",
		"autoconnect": true,
	}

	settings["ipv4"] = map[string]interface{}{"method": "auto"}
	settings["ipv6"] = map[string]interface{}{"method": "auto"}

	if secured {
		settings["802-11-wireless"] = map[string]interface{}{
			"ssid":     []byte(req.SSID),
			"mode":     "infrastructure",
			"security": "802-11-wireless-security",
		}

		switch {
		case isEnterprise || req.Username != "":
			settings["802-11-wireless-security"] = map[string]interface{}{
				"key-mgmt": "wpa-eap",
			}

			x := map[string]interface{}{
				"eap":             []string{"peap"},
				"phase2-auth":     "mschapv2",
				"system-ca-certs": false,
				"password-flags":  uint32(0),
			}

			if req.Username != "" {
				x["identity"] = req.Username
			}
			if req.Password != "" {
				x["password"] = req.Password
			}

			if req.AnonymousIdentity != "" {
				x["anonymous-identity"] = req.AnonymousIdentity
			}
			if req.DomainSuffixMatch != "" {
				x["domain-suffix-match"] = req.DomainSuffixMatch
			}

			settings["802-1x"] = x

			log.Infof("[createAndConnectWiFi] WPA-EAP settings: eap=peap, phase2-auth=mschapv2, identity=%s, interactive=%v, system-ca-certs=%v, domain-suffix-match=%q",
				req.Username, req.Interactive, x["system-ca-certs"], req.DomainSuffixMatch)

		case isPsk:
			sec := map[string]interface{}{
				"key-mgmt":  "wpa-psk",
				"psk-flags": uint32(0),
			}
			if !req.Interactive {
				sec["psk"] = req.Password
			}
			settings["802-11-wireless-security"] = sec

		case isSae:
			sec := map[string]interface{}{
				"key-mgmt":  "sae",
				"pmf":       int32(3),
				"psk-flags": uint32(0),
			}
			if !req.Interactive {
				sec["psk"] = req.Password
			}
			settings["802-11-wireless-security"] = sec

		default:
			return fmt.Errorf("secured network but not SAE/PSK/802.1X (rsn=0x%x wpa=0x%x)", rsnFlags, wpaFlags)
		}
	} else {
		settings["802-11-wireless"] = map[string]interface{}{
			"ssid": []byte(req.SSID),
			"mode": "infrastructure",
		}
	}

	if req.Interactive {
		s := b.settings
		if s == nil {
			var settingsErr error
			s, settingsErr = gonetworkmanager.NewSettings()
			if settingsErr != nil {
				return fmt.Errorf("failed to get settings manager: %w", settingsErr)
			}
			b.settings = s
		}

		settingsMgr := s.(gonetworkmanager.Settings)
		conn, err := settingsMgr.AddConnection(settings)
		if err != nil {
			return fmt.Errorf("failed to add connection: %w", err)
		}

		if isEnterprise {
			log.Infof("[createAndConnectWiFi] Enterprise connection added, activating (secret agent will be called)")
		}

		_, err = nm.ActivateWirelessConnection(conn, dev, targetAP)
		if err != nil {
			return fmt.Errorf("failed to activate connection: %w", err)
		}

		log.Infof("[createAndConnectWiFi] Connection activation initiated, waiting for NetworkManager state changes...")
	} else {
		_, err = nm.AddAndActivateWirelessConnection(settings, dev, targetAP)
		if err != nil {
			return fmt.Errorf("failed to connect: %w", err)
		}
		log.Infof("[createAndConnectWiFi] Connection activation initiated, waiting for NetworkManager state changes...")
	}

	return nil
}

func (b *NetworkManagerBackend) SetWiFiAutoconnect(ssid string, autoconnect bool) error {
	conn, err := b.findConnection(ssid)
	if err != nil {
		return fmt.Errorf("connection not found: %w", err)
	}

	settings, err := conn.GetSettings()
	if err != nil {
		return fmt.Errorf("failed to get connection settings: %w", err)
	}

	if connMeta, ok := settings["connection"]; ok {
		connMeta["autoconnect"] = autoconnect
	} else {
		return fmt.Errorf("connection metadata not found")
	}

	if ipv4, ok := settings["ipv4"]; ok {
		delete(ipv4, "addresses")
		delete(ipv4, "routes")
		delete(ipv4, "dns")
	}

	if ipv6, ok := settings["ipv6"]; ok {
		delete(ipv6, "addresses")
		delete(ipv6, "routes")
		delete(ipv6, "dns")
	}

	err = conn.Update(settings)
	if err != nil {
		return fmt.Errorf("failed to update connection: %w", err)
	}

	b.updateWiFiNetworks()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	return nil
}
