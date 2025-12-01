package network

import (
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/Wifx/gonetworkmanager/v2"
)

func (b *NetworkManagerBackend) ListVPNProfiles() ([]VPNProfile, error) {
	s := b.settings
	if s == nil {
		var err error
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

	var profiles []VPNProfile
	for _, conn := range connections {
		settings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		connMeta, ok := settings["connection"]
		if !ok {
			continue
		}

		connType, _ := connMeta["type"].(string)
		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		connID, _ := connMeta["id"].(string)
		connUUID, _ := connMeta["uuid"].(string)

		profile := VPNProfile{
			Name: connID,
			UUID: connUUID,
			Type: connType,
		}

		if connType == "vpn" {
			if vpnSettings, ok := settings["vpn"]; ok {
				if svcType, ok := vpnSettings["service-type"].(string); ok {
					profile.ServiceType = svcType
				}
			}
		}

		profiles = append(profiles, profile)
	}

	sort.Slice(profiles, func(i, j int) bool {
		return strings.ToLower(profiles[i].Name) < strings.ToLower(profiles[j].Name)
	})

	b.stateMutex.Lock()
	b.state.VPNProfiles = profiles
	b.stateMutex.Unlock()

	return profiles, nil
}

func (b *NetworkManagerBackend) ListActiveVPN() ([]VPNActive, error) {
	nm := b.nmConn.(gonetworkmanager.NetworkManager)

	activeConns, err := nm.GetPropertyActiveConnections()
	if err != nil {
		return nil, fmt.Errorf("failed to get active connections: %w", err)
	}

	var active []VPNActive
	for _, activeConn := range activeConns {
		connType, err := activeConn.GetPropertyType()
		if err != nil {
			continue
		}

		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		uuid, _ := activeConn.GetPropertyUUID()
		id, _ := activeConn.GetPropertyID()
		state, _ := activeConn.GetPropertyState()

		var stateStr string
		switch state {
		case 0:
			stateStr = "unknown"
		case 1:
			stateStr = "activating"
		case 2:
			stateStr = "activated"
		case 3:
			stateStr = "deactivating"
		case 4:
			stateStr = "deactivated"
		}

		vpnActive := VPNActive{
			Name:   id,
			UUID:   uuid,
			State:  stateStr,
			Type:   connType,
			Plugin: "",
		}

		if connType == "vpn" {
			conn, _ := activeConn.GetPropertyConnection()
			if conn != nil {
				connSettings, err := conn.GetSettings()
				if err == nil {
					if vpnSettings, ok := connSettings["vpn"]; ok {
						if svcType, ok := vpnSettings["service-type"].(string); ok {
							vpnActive.Plugin = svcType
						}
					}
				}
			}
		}

		active = append(active, vpnActive)
	}

	b.stateMutex.Lock()
	b.state.VPNActive = active
	b.stateMutex.Unlock()

	return active, nil
}

func (b *NetworkManagerBackend) ConnectVPN(uuidOrName string, singleActive bool) error {
	if singleActive {
		active, err := b.ListActiveVPN()
		if err == nil && len(active) > 0 {
			alreadyConnected := false
			for _, vpn := range active {
				if vpn.UUID == uuidOrName || vpn.Name == uuidOrName {
					alreadyConnected = true
					break
				}
			}

			if !alreadyConnected {
				if err := b.DisconnectAllVPN(); err != nil {
					log.Warnf("Failed to disconnect existing VPNs: %v", err)
				}
				time.Sleep(500 * time.Millisecond)
			} else {
				return nil
			}
		}
	}

	s := b.settings
	if s == nil {
		var err error
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return fmt.Errorf("failed to get settings: %w", err)
		}
		b.settings = s
	}

	settingsMgr := s.(gonetworkmanager.Settings)
	connections, err := settingsMgr.ListConnections()
	if err != nil {
		return fmt.Errorf("failed to get connections: %w", err)
	}

	var targetConn gonetworkmanager.Connection
	for _, conn := range connections {
		settings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		connMeta, ok := settings["connection"]
		if !ok {
			continue
		}

		connType, _ := connMeta["type"].(string)
		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		connID, _ := connMeta["id"].(string)
		connUUID, _ := connMeta["uuid"].(string)

		if connUUID == uuidOrName || connID == uuidOrName {
			targetConn = conn
			break
		}
	}

	if targetConn == nil {
		return fmt.Errorf("VPN connection not found: %s", uuidOrName)
	}

	targetSettings, err := targetConn.GetSettings()
	if err != nil {
		return fmt.Errorf("failed to get connection settings: %w", err)
	}

	var targetUUID string
	if connMeta, ok := targetSettings["connection"]; ok {
		if uuid, ok := connMeta["uuid"].(string); ok {
			targetUUID = uuid
		}
	}

	b.stateMutex.Lock()
	b.state.IsConnectingVPN = true
	b.state.ConnectingVPNUUID = targetUUID
	b.stateMutex.Unlock()

	if b.onStateChange != nil {
		b.onStateChange()
	}

	nm := b.nmConn.(gonetworkmanager.NetworkManager)
	activeConn, err := nm.ActivateConnection(targetConn, nil, nil)
	if err != nil {
		b.stateMutex.Lock()
		b.state.IsConnectingVPN = false
		b.state.ConnectingVPNUUID = ""
		b.stateMutex.Unlock()

		if b.onStateChange != nil {
			b.onStateChange()
		}

		return fmt.Errorf("failed to activate VPN: %w", err)
	}

	if activeConn != nil {
		state, _ := activeConn.GetPropertyState()
		if state == 2 {
			b.stateMutex.Lock()
			b.state.IsConnectingVPN = false
			b.state.ConnectingVPNUUID = ""
			b.stateMutex.Unlock()
			b.ListActiveVPN()
			if b.onStateChange != nil {
				b.onStateChange()
			}
		}
	}

	return nil
}

func (b *NetworkManagerBackend) DisconnectVPN(uuidOrName string) error {
	nm := b.nmConn.(gonetworkmanager.NetworkManager)

	activeConns, err := nm.GetPropertyActiveConnections()
	if err != nil {
		return fmt.Errorf("failed to get active connections: %w", err)
	}

	log.Debugf("[DisconnectVPN] Looking for VPN: %s", uuidOrName)

	for _, activeConn := range activeConns {
		connType, err := activeConn.GetPropertyType()
		if err != nil {
			continue
		}

		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		uuid, _ := activeConn.GetPropertyUUID()
		id, _ := activeConn.GetPropertyID()
		state, _ := activeConn.GetPropertyState()

		log.Debugf("[DisconnectVPN] Found active VPN: uuid=%s id=%s state=%d", uuid, id, state)

		if uuid == uuidOrName || id == uuidOrName {
			log.Infof("[DisconnectVPN] Deactivating VPN: %s (state=%d)", id, state)
			if err := nm.DeactivateConnection(activeConn); err != nil {
				return fmt.Errorf("failed to deactivate VPN: %w", err)
			}
			b.ListActiveVPN()
			if b.onStateChange != nil {
				b.onStateChange()
			}
			return nil
		}
	}

	log.Warnf("[DisconnectVPN] VPN not found in active connections: %s", uuidOrName)

	s := b.settings
	if s == nil {
		var err error
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return fmt.Errorf("VPN connection not active and cannot access settings: %w", err)
		}
		b.settings = s
	}

	settingsMgr := s.(gonetworkmanager.Settings)
	connections, err := settingsMgr.ListConnections()
	if err != nil {
		return fmt.Errorf("VPN connection not active: %s", uuidOrName)
	}

	for _, conn := range connections {
		settings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		connMeta, ok := settings["connection"]
		if !ok {
			continue
		}

		connType, _ := connMeta["type"].(string)
		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		connID, _ := connMeta["id"].(string)
		connUUID, _ := connMeta["uuid"].(string)

		if connUUID == uuidOrName || connID == uuidOrName {
			log.Infof("[DisconnectVPN] VPN connection exists but not active: %s", connID)
			return nil
		}
	}

	return fmt.Errorf("VPN connection not found: %s", uuidOrName)
}

func (b *NetworkManagerBackend) DisconnectAllVPN() error {
	nm := b.nmConn.(gonetworkmanager.NetworkManager)

	activeConns, err := nm.GetPropertyActiveConnections()
	if err != nil {
		return fmt.Errorf("failed to get active connections: %w", err)
	}

	var lastErr error
	var disconnected bool
	for _, activeConn := range activeConns {
		connType, err := activeConn.GetPropertyType()
		if err != nil {
			continue
		}

		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		if err := nm.DeactivateConnection(activeConn); err != nil {
			lastErr = err
			log.Warnf("Failed to deactivate VPN connection: %v", err)
		} else {
			disconnected = true
		}
	}

	if disconnected {
		b.ListActiveVPN()
		if b.onStateChange != nil {
			b.onStateChange()
		}
	}

	return lastErr
}

func (b *NetworkManagerBackend) ClearVPNCredentials(uuidOrName string) error {
	s := b.settings
	if s == nil {
		var err error
		s, err = gonetworkmanager.NewSettings()
		if err != nil {
			return fmt.Errorf("failed to get settings: %w", err)
		}
		b.settings = s
	}

	settingsMgr := s.(gonetworkmanager.Settings)
	connections, err := settingsMgr.ListConnections()
	if err != nil {
		return fmt.Errorf("failed to get connections: %w", err)
	}

	for _, conn := range connections {
		settings, err := conn.GetSettings()
		if err != nil {
			continue
		}

		connMeta, ok := settings["connection"]
		if !ok {
			continue
		}

		connType, _ := connMeta["type"].(string)
		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		connID, _ := connMeta["id"].(string)
		connUUID, _ := connMeta["uuid"].(string)

		if connUUID == uuidOrName || connID == uuidOrName {
			if connType == "vpn" {
				if vpnSettings, ok := settings["vpn"]; ok {
					delete(vpnSettings, "secrets")

					if dataMap, ok := vpnSettings["data"].(map[string]string); ok {
						dataMap["password-flags"] = "1"
						vpnSettings["data"] = dataMap
					}

					vpnSettings["password-flags"] = uint32(1)
				}

				settings["vpn-secrets"] = make(map[string]interface{})
			}

			if err := conn.Update(settings); err != nil {
				return fmt.Errorf("failed to update connection: %w", err)
			}

			if err := conn.ClearSecrets(); err != nil {
				log.Warnf("ClearSecrets call failed (may not be critical): %v", err)
			}

			log.Infof("Cleared credentials for VPN: %s", connID)
			return nil
		}
	}

	return fmt.Errorf("VPN connection not found: %s", uuidOrName)
}

func (b *NetworkManagerBackend) updateVPNConnectionState() {
	b.stateMutex.RLock()
	isConnectingVPN := b.state.IsConnectingVPN
	connectingVPNUUID := b.state.ConnectingVPNUUID
	b.stateMutex.RUnlock()

	if !isConnectingVPN || connectingVPNUUID == "" {
		return
	}

	nm := b.nmConn.(gonetworkmanager.NetworkManager)
	activeConns, err := nm.GetPropertyActiveConnections()
	if err != nil {
		return
	}

	foundConnection := false
	for _, activeConn := range activeConns {
		connType, err := activeConn.GetPropertyType()
		if err != nil {
			continue
		}

		if connType != "vpn" && connType != "wireguard" {
			continue
		}

		uuid, err := activeConn.GetPropertyUUID()
		if err != nil {
			continue
		}

		state, _ := activeConn.GetPropertyState()
		stateReason, _ := activeConn.GetPropertyStateFlags()

		if uuid == connectingVPNUUID {
			foundConnection = true

			switch state {
			case 2:
				log.Infof("[updateVPNConnectionState] VPN connection successful: %s", uuid)
				b.stateMutex.Lock()
				b.state.IsConnectingVPN = false
				b.state.ConnectingVPNUUID = ""
				b.state.LastError = ""
				b.stateMutex.Unlock()
				return
			case 4:
				log.Warnf("[updateVPNConnectionState] VPN connection failed/deactivated: %s (state=%d, flags=%d)", uuid, state, stateReason)
				b.stateMutex.Lock()
				b.state.IsConnectingVPN = false
				b.state.ConnectingVPNUUID = ""
				b.state.LastError = "VPN connection failed"
				b.stateMutex.Unlock()
				return
			}
		}
	}

	if !foundConnection {
		log.Warnf("[updateVPNConnectionState] VPN connection no longer exists: %s", connectingVPNUUID)
		b.stateMutex.Lock()
		b.state.IsConnectingVPN = false
		b.state.ConnectingVPNUUID = ""
		b.state.LastError = "VPN connection failed"
		b.stateMutex.Unlock()
	}
}
