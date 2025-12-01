package network

import (
	"github.com/Wifx/gonetworkmanager/v2"
	"github.com/godbus/dbus/v5"
)

func (b *NetworkManagerBackend) startSignalPump() error {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return err
	}
	b.dbusConn = conn

	signals := make(chan *dbus.Signal, 256)
	b.signals = signals
	conn.Signal(signals)

	if err := conn.AddMatchSignal(
		dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
		dbus.WithMatchInterface(dbusPropsInterface),
		dbus.WithMatchMember("PropertiesChanged"),
	); err != nil {
		conn.RemoveSignal(signals)
		conn.Close()
		return err
	}

	if err := conn.AddMatchSignal(
		dbus.WithMatchObjectPath(dbus.ObjectPath("/org/freedesktop/NetworkManager/Settings")),
		dbus.WithMatchInterface("org.freedesktop.NetworkManager.Settings"),
		dbus.WithMatchMember("NewConnection"),
	); err != nil {
		conn.RemoveMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		)
		conn.RemoveSignal(signals)
		conn.Close()
		return err
	}

	if err := conn.AddMatchSignal(
		dbus.WithMatchObjectPath(dbus.ObjectPath("/org/freedesktop/NetworkManager/Settings")),
		dbus.WithMatchInterface("org.freedesktop.NetworkManager.Settings"),
		dbus.WithMatchMember("ConnectionRemoved"),
	); err != nil {
		conn.RemoveMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		)
		conn.RemoveMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath("/org/freedesktop/NetworkManager/Settings")),
			dbus.WithMatchInterface("org.freedesktop.NetworkManager.Settings"),
			dbus.WithMatchMember("NewConnection"),
		)
		conn.RemoveSignal(signals)
		conn.Close()
		return err
	}

	if b.wifiDevice != nil {
		dev := b.wifiDevice.(gonetworkmanager.Device)
		if err := conn.AddMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dev.GetPath())),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		); err != nil {
			conn.RemoveMatchSignal(
				dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
				dbus.WithMatchInterface(dbusPropsInterface),
				dbus.WithMatchMember("PropertiesChanged"),
			)
			conn.RemoveSignal(signals)
			conn.Close()
			return err
		}
	}

	if b.ethernetDevice != nil {
		dev := b.ethernetDevice.(gonetworkmanager.Device)
		if err := conn.AddMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dev.GetPath())),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		); err != nil {
			conn.RemoveMatchSignal(
				dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
				dbus.WithMatchInterface(dbusPropsInterface),
				dbus.WithMatchMember("PropertiesChanged"),
			)
			if b.wifiDevice != nil {
				dev := b.wifiDevice.(gonetworkmanager.Device)
				conn.RemoveMatchSignal(
					dbus.WithMatchObjectPath(dbus.ObjectPath(dev.GetPath())),
					dbus.WithMatchInterface(dbusPropsInterface),
					dbus.WithMatchMember("PropertiesChanged"),
				)
			}
			conn.RemoveSignal(signals)
			conn.Close()
			return err
		}
	}

	b.sigWG.Add(1)
	go func() {
		defer b.sigWG.Done()
		for {
			select {
			case <-b.stopChan:
				return
			case sig, ok := <-signals:
				if !ok {
					return
				}
				if sig == nil {
					continue
				}
				b.handleDBusSignal(sig)
			}
		}
	}()
	return nil
}

func (b *NetworkManagerBackend) stopSignalPump() {
	if b.dbusConn == nil {
		return
	}

	b.dbusConn.RemoveMatchSignal(
		dbus.WithMatchObjectPath(dbus.ObjectPath(dbusNMPath)),
		dbus.WithMatchInterface(dbusPropsInterface),
		dbus.WithMatchMember("PropertiesChanged"),
	)

	if b.wifiDevice != nil {
		dev := b.wifiDevice.(gonetworkmanager.Device)
		b.dbusConn.RemoveMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dev.GetPath())),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		)
	}

	if b.ethernetDevice != nil {
		dev := b.ethernetDevice.(gonetworkmanager.Device)
		b.dbusConn.RemoveMatchSignal(
			dbus.WithMatchObjectPath(dbus.ObjectPath(dev.GetPath())),
			dbus.WithMatchInterface(dbusPropsInterface),
			dbus.WithMatchMember("PropertiesChanged"),
		)
	}

	if b.signals != nil {
		b.dbusConn.RemoveSignal(b.signals)
		close(b.signals)
	}

	b.sigWG.Wait()

	b.dbusConn.Close()
}

func (b *NetworkManagerBackend) handleDBusSignal(sig *dbus.Signal) {
	if sig.Name == "org.freedesktop.NetworkManager.Settings.NewConnection" ||
		sig.Name == "org.freedesktop.NetworkManager.Settings.ConnectionRemoved" {
		b.ListVPNProfiles()
		if b.onStateChange != nil {
			b.onStateChange()
		}
		return
	}

	if len(sig.Body) < 2 {
		return
	}

	iface, ok := sig.Body[0].(string)
	if !ok {
		return
	}

	changes, ok := sig.Body[1].(map[string]dbus.Variant)
	if !ok {
		return
	}

	switch iface {
	case dbusNMInterface:
		b.handleNetworkManagerChange(changes)

	case dbusNMDeviceInterface:
		b.handleDeviceChange(changes)

	case dbusNMWirelessInterface:
		b.handleWiFiChange(changes)

	case dbusNMAccessPointInterface:
		b.handleAccessPointChange(changes)
	}
}

func (b *NetworkManagerBackend) handleNetworkManagerChange(changes map[string]dbus.Variant) {
	var needsUpdate bool

	for key := range changes {
		switch key {
		case "PrimaryConnection", "State", "ActiveConnections":
			needsUpdate = true
		case "WirelessEnabled":
			nm := b.nmConn.(gonetworkmanager.NetworkManager)
			if enabled, err := nm.GetPropertyWirelessEnabled(); err == nil {
				b.stateMutex.Lock()
				b.state.WiFiEnabled = enabled
				b.stateMutex.Unlock()
				needsUpdate = true
			}
		default:
			continue
		}
	}

	if needsUpdate {
		b.updatePrimaryConnection()
		if _, exists := changes["State"]; exists {
			b.updateEthernetState()
			b.updateWiFiState()
		}
		if _, exists := changes["ActiveConnections"]; exists {
			b.updateVPNConnectionState()
			b.ListActiveVPN()
		}
		if b.onStateChange != nil {
			b.onStateChange()
		}
	}
}

func (b *NetworkManagerBackend) handleDeviceChange(changes map[string]dbus.Variant) {
	var needsUpdate bool
	var stateChanged bool

	for key := range changes {
		switch key {
		case "State":
			stateChanged = true
			needsUpdate = true
		case "Ip4Config":
			needsUpdate = true
		default:
			continue
		}
	}

	if needsUpdate {
		b.updateEthernetState()
		b.updateWiFiState()
		if stateChanged {
			b.updatePrimaryConnection()
		}
		if b.onStateChange != nil {
			b.onStateChange()
		}
	}
}

func (b *NetworkManagerBackend) handleWiFiChange(changes map[string]dbus.Variant) {
	var needsStateUpdate bool
	var needsNetworkUpdate bool

	for key := range changes {
		switch key {
		case "ActiveAccessPoint":
			needsStateUpdate = true
			needsNetworkUpdate = true
		case "AccessPoints":
			needsNetworkUpdate = true
		default:
			continue
		}
	}

	if needsStateUpdate {
		b.updateWiFiState()
	}
	if needsNetworkUpdate {
		b.updateWiFiNetworks()
	}
	if needsStateUpdate || needsNetworkUpdate {
		if b.onStateChange != nil {
			b.onStateChange()
		}
	}
}

func (b *NetworkManagerBackend) handleAccessPointChange(changes map[string]dbus.Variant) {
	_, hasStrength := changes["Strength"]
	if !hasStrength {
		return
	}

	b.stateMutex.RLock()
	oldSignal := b.state.WiFiSignal
	b.stateMutex.RUnlock()

	b.updateWiFiState()

	b.stateMutex.RLock()
	newSignal := b.state.WiFiSignal
	b.stateMutex.RUnlock()

	if signalChangeSignificant(oldSignal, newSignal) {
		if b.onStateChange != nil {
			b.onStateChange()
		}
	}
}
