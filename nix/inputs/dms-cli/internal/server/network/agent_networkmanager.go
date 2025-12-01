package network

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/AvengeMedia/danklinux/internal/errdefs"
	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/godbus/dbus/v5"
)

const (
	nmAgentManagerPath  = "/org/freedesktop/NetworkManager/AgentManager"
	nmAgentManagerIface = "org.freedesktop.NetworkManager.AgentManager"
	nmSecretAgentIface  = "org.freedesktop.NetworkManager.SecretAgent"
	agentObjectPath     = "/org/freedesktop/NetworkManager/SecretAgent"
	agentIdentifier     = "com.danklinux.NMAgent"
)

type SecretAgent struct {
	conn    *dbus.Conn
	objPath dbus.ObjectPath
	id      string
	prompts PromptBroker
	manager *Manager
	backend *NetworkManagerBackend
}

type nmVariantMap map[string]dbus.Variant
type nmSettingMap map[string]nmVariantMap

const introspectXML = `
<node>
	<interface name="org.freedesktop.NetworkManager.SecretAgent">
		<method name="GetSecrets">
			<arg type="a{sa{sv}}" name="connection" direction="in"/>
			<arg type="o" name="connection_path" direction="in"/>
			<arg type="s" name="setting_name" direction="in"/>
			<arg type="as" name="hints" direction="in"/>
			<arg type="u" name="flags" direction="in"/>
			<arg type="a{sa{sv}}" name="secrets" direction="out"/>
		</method>
		<method name="DeleteSecrets">
			<arg type="a{sa{sv}}" name="connection" direction="in"/>
			<arg type="o" name="connection_path" direction="in"/>
		</method>
		<method name="DeleteSecrets2">
			<arg type="o" name="connection_path" direction="in"/>
			<arg type="s" name="setting" direction="in"/>
		</method>
		<method name="CancelGetSecrets">
			<arg type="o" name="connection_path" direction="in"/>
			<arg type="s" name="setting_name" direction="in"/>
		</method>
	</interface>
	<interface name="org.freedesktop.DBus.Introspectable">
		<method name="Introspect">
			<arg name="data" type="s" direction="out"/>
		</method>
	</interface>
</node>`

func NewSecretAgent(prompts PromptBroker, manager *Manager, backend *NetworkManagerBackend) (*SecretAgent, error) {
	c, err := dbus.ConnectSystemBus()
	if err != nil {
		return nil, fmt.Errorf("failed to connect to system bus: %w", err)
	}

	sa := &SecretAgent{
		conn:    c,
		objPath: dbus.ObjectPath(agentObjectPath),
		id:      agentIdentifier,
		prompts: prompts,
		manager: manager,
		backend: backend,
	}

	if err := c.Export(sa, sa.objPath, nmSecretAgentIface); err != nil {
		c.Close()
		return nil, fmt.Errorf("failed to export secret agent: %w", err)
	}

	if err := c.Export(sa, sa.objPath, "org.freedesktop.DBus.Introspectable"); err != nil {
		c.Close()
		return nil, fmt.Errorf("failed to export introspection: %w", err)
	}

	mgr := c.Object("org.freedesktop.NetworkManager", dbus.ObjectPath(nmAgentManagerPath))
	call := mgr.Call(nmAgentManagerIface+".Register", 0, sa.id)
	if call.Err != nil {
		c.Close()
		return nil, fmt.Errorf("failed to register agent with NetworkManager: %w", call.Err)
	}

	log.Infof("[SecretAgent] Registered with NetworkManager (id=%s, unique name=%s, fixed path=%s)", sa.id, c.Names()[0], sa.objPath)
	return sa, nil
}

func (a *SecretAgent) Close() {
	if a.conn != nil {
		mgr := a.conn.Object("org.freedesktop.NetworkManager", dbus.ObjectPath(nmAgentManagerPath))
		mgr.Call(nmAgentManagerIface+".Unregister", 0, a.id)
		a.conn.Close()
	}
}

func (a *SecretAgent) GetSecrets(
	conn map[string]nmVariantMap,
	path dbus.ObjectPath,
	settingName string,
	hints []string,
	flags uint32,
) (nmSettingMap, *dbus.Error) {
	log.Infof("[SecretAgent] GetSecrets called: path=%s, setting=%s, hints=%v, flags=%d",
		path, settingName, hints, flags)

	const (
		NM_SECRET_AGENT_GET_SECRETS_FLAG_ALLOW_INTERACTION = 0x1
		NM_SECRET_AGENT_GET_SECRETS_FLAG_REQUEST_NEW       = 0x2
		NM_SECRET_AGENT_GET_SECRETS_FLAG_USER_REQUESTED    = 0x4
	)

	connType, displayName, vpnSvc := readConnTypeAndName(conn)
	ssid := readSSID(conn)
	fields := fieldsNeeded(settingName, hints)

	log.Infof("[SecretAgent] connType=%s, name=%s, vpnSvc=%s, fields=%v, flags=%d", connType, displayName, vpnSvc, fields, flags)

	if a.backend != nil {
		a.backend.stateMutex.RLock()
		isConnecting := a.backend.state.IsConnecting
		connectingSSID := a.backend.state.ConnectingSSID
		isConnectingVPN := a.backend.state.IsConnectingVPN
		connectingVPNUUID := a.backend.state.ConnectingVPNUUID
		a.backend.stateMutex.RUnlock()

		switch connType {
		case "802-11-wireless":
			// If we're connecting to a WiFi network, only respond if it's the one we're connecting to
			if isConnecting && connectingSSID != ssid {
				log.Infof("[SecretAgent] Ignoring WiFi request for SSID '%s' - we're connecting to '%s'", ssid, connectingSSID)
				return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.NoSecrets", nil)
			}
		case "vpn", "wireguard":
			var connUuid string
			if c, ok := conn["connection"]; ok {
				if v, ok := c["uuid"]; ok {
					if s, ok2 := v.Value().(string); ok2 {
						connUuid = s
					}
				}
			}

			// If we're connecting to a VPN, only respond if it's the one we're connecting to
			// This prevents interfering with nmcli/other tools when our app isn't connecting
			if isConnectingVPN && connUuid != connectingVPNUUID {
				log.Infof("[SecretAgent] Ignoring VPN request for UUID '%s' - we're connecting to '%s'", connUuid, connectingVPNUUID)
				return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.NoSecrets", nil)
			}
		}
	}

	if len(fields) == 0 {
		// For VPN connections with no hints, we can't provide a proper UI.
		// Defer to other agents (like nm-applet or VPN-specific auth dialogs)
		// that can handle the VPN type properly (e.g., OpenConnect with SAML, etc.)
		if settingName == "vpn" {
			log.Infof("[SecretAgent] VPN with empty hints - deferring to other agents for %s", vpnSvc)
			return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.NoSecrets", nil)
		}

		const (
			NM_SETTING_SECRET_FLAG_NONE         = 0
			NM_SETTING_SECRET_FLAG_AGENT_OWNED  = 1
			NM_SETTING_SECRET_FLAG_NOT_SAVED    = 2
			NM_SETTING_SECRET_FLAG_NOT_REQUIRED = 4
		)

		var passwordFlags uint32 = 0xFFFF
		switch settingName {
		case "802-11-wireless-security":
			if wifiSecSettings, ok := conn["802-11-wireless-security"]; ok {
				if flagsVariant, ok := wifiSecSettings["psk-flags"]; ok {
					if pwdFlags, ok := flagsVariant.Value().(uint32); ok {
						passwordFlags = pwdFlags
					}
				}
			}
		case "802-1x":
			if dot1xSettings, ok := conn["802-1x"]; ok {
				if flagsVariant, ok := dot1xSettings["password-flags"]; ok {
					if pwdFlags, ok := flagsVariant.Value().(uint32); ok {
						passwordFlags = pwdFlags
					}
				}
			}
		}

		if passwordFlags == 0xFFFF {
			log.Warnf("[SecretAgent] Could not determine password-flags for empty hints - returning NoSecrets error")
			return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.NoSecrets", nil)
		} else if passwordFlags&NM_SETTING_SECRET_FLAG_NOT_REQUIRED != 0 {
			log.Infof("[SecretAgent] Secrets not required (flags=%d)", passwordFlags)
			out := nmSettingMap{}
			out[settingName] = nmVariantMap{}
			return out, nil
		} else if passwordFlags&NM_SETTING_SECRET_FLAG_AGENT_OWNED != 0 {
			log.Warnf("[SecretAgent] Secrets are agent-owned but we don't store secrets (flags=%d) - returning NoSecrets error", passwordFlags)
			return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.NoSecrets", nil)
		} else {
			log.Infof("[SecretAgent] No secrets needed, using system stored secrets (flags=%d)", passwordFlags)
			out := nmSettingMap{}
			out[settingName] = nmVariantMap{}
			return out, nil
		}
	}

	reason := reasonFromFlags(flags)
	if a.manager != nil && connType == "802-11-wireless" && a.manager.WasRecentlyFailed(ssid) {
		reason = "wrong-password"
	}

	var connId, connUuid string
	if c, ok := conn["connection"]; ok {
		if v, ok := c["id"]; ok {
			if s, ok2 := v.Value().(string); ok2 {
				connId = s
			}
		}
		if v, ok := c["uuid"]; ok {
			if s, ok2 := v.Value().(string); ok2 {
				connUuid = s
			}
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()

	token, err := a.prompts.Ask(ctx, PromptRequest{
		Name:           displayName,
		SSID:           ssid,
		ConnType:       connType,
		VpnService:     vpnSvc,
		SettingName:    settingName,
		Fields:         fields,
		Hints:          hints,
		Reason:         reason,
		ConnectionId:   connId,
		ConnectionUuid: connUuid,
		ConnectionPath: string(path),
	})
	if err != nil {
		log.Warnf("[SecretAgent] Failed to create prompt: %v", err)
		return nil, dbus.MakeFailedError(err)
	}

	log.Infof("[SecretAgent] Waiting for user input (token=%s)", token)
	reply, err := a.prompts.Wait(ctx, token)
	if err != nil {
		log.Warnf("[SecretAgent] Prompt failed or cancelled: %v", err)

		if reply.Cancel || errors.Is(err, errdefs.ErrSecretPromptCancelled) {
			return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.UserCanceled", nil)
		}

		if errors.Is(err, errdefs.ErrSecretPromptTimeout) {
			return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.Failed", nil)
		}
		return nil, dbus.NewError("org.freedesktop.NetworkManager.SecretAgent.Error.Failed", nil)
	}

	log.Infof("[SecretAgent] User provided secrets, save=%v", reply.Save)

	out := nmSettingMap{}
	sec := nmVariantMap{}
	for k, v := range reply.Secrets {
		sec[k] = dbus.MakeVariant(v)
	}
	out[settingName] = sec

	switch settingName {
	case "802-1x":
		log.Infof("[SecretAgent] Returning 802-1x enterprise secrets with %d fields", len(sec))
	case "vpn":
		log.Infof("[SecretAgent] Returning VPN secrets with %d fields for %s", len(sec), vpnSvc)
	}

	// If save=true, persist secrets in background after returning to NetworkManager
	// This MUST happen after we return secrets, in a goroutine
	if reply.Save {
		go func() {
			log.Infof("[SecretAgent] Persisting secrets with Update2: path=%s, setting=%s", path, settingName)

			// Get existing connection settings
			connObj := a.conn.Object("org.freedesktop.NetworkManager", path)
			var existingSettings map[string]map[string]dbus.Variant
			if err := connObj.Call("org.freedesktop.NetworkManager.Settings.Connection.GetSettings", 0).Store(&existingSettings); err != nil {
				log.Warnf("[SecretAgent] GetSettings failed: %v", err)
				return
			}

			// Build minimal settings with ONLY the section we're updating
			// This avoids D-Bus type serialization issues with complex types like IPv6 addresses
			settings := make(map[string]map[string]dbus.Variant)

			// Copy connection section (required for Update2)
			if connSection, ok := existingSettings["connection"]; ok {
				settings["connection"] = connSection
			}

			// Update settings based on type
			switch settingName {
			case "vpn":
				// Set password-flags=0 and add secrets to vpn section
				vpn, ok := existingSettings["vpn"]
				if !ok {
					vpn = make(map[string]dbus.Variant)
				}

				// Get existing data map (vpn.data is string->string)
				var data map[string]string
				if dataVariant, ok := vpn["data"]; ok {
					if dm, ok := dataVariant.Value().(map[string]string); ok {
						data = make(map[string]string)
						for k, v := range dm {
							data[k] = v
						}
					} else {
						data = make(map[string]string)
					}
				} else {
					data = make(map[string]string)
				}

				// Update password-flags to 0 (system-stored)
				data["password-flags"] = "0"
				vpn["data"] = dbus.MakeVariant(data)

				// Add secrets (vpn.secrets is string->string)
				secs := make(map[string]string)
				for k, v := range reply.Secrets {
					secs[k] = v
				}
				vpn["secrets"] = dbus.MakeVariant(secs)
				settings["vpn"] = vpn

				log.Infof("[SecretAgent] Updated VPN settings: password-flags=0, secrets with %d fields", len(secs))

			case "802-11-wireless-security":
				// Set psk-flags=0 for WiFi
				wifiSec, ok := existingSettings["802-11-wireless-security"]
				if !ok {
					wifiSec = make(map[string]dbus.Variant)
				}
				wifiSec["psk-flags"] = dbus.MakeVariant(uint32(0))

				// Add PSK secret
				if psk, ok := reply.Secrets["psk"]; ok {
					wifiSec["psk"] = dbus.MakeVariant(psk)
					log.Infof("[SecretAgent] Updated WiFi settings: psk-flags=0")
				}
				settings["802-11-wireless-security"] = wifiSec

			case "802-1x":
				// Set password-flags=0 for 802.1x
				dot1x, ok := existingSettings["802-1x"]
				if !ok {
					dot1x = make(map[string]dbus.Variant)
				}
				dot1x["password-flags"] = dbus.MakeVariant(uint32(0))

				// Add password secret
				if password, ok := reply.Secrets["password"]; ok {
					dot1x["password"] = dbus.MakeVariant(password)
					log.Infof("[SecretAgent] Updated 802.1x settings: password-flags=0")
				}
				settings["802-1x"] = dot1x
			}

			// Call Update2 with correct signature:
			// Update2(IN settings, IN flags, IN args) -> OUT result
			// flags: 0x1 = to-disk
			var result map[string]dbus.Variant
			err := connObj.Call("org.freedesktop.NetworkManager.Settings.Connection.Update2", 0,
				settings, uint32(0x1), map[string]dbus.Variant{}).Store(&result)
			if err != nil {
				log.Warnf("[SecretAgent] Update2(to-disk) failed: %v", err)
			} else {
				log.Infof("[SecretAgent] Successfully persisted secrets to disk for %s", settingName)
			}
		}()
	}

	return out, nil
}

func (a *SecretAgent) DeleteSecrets(conn map[string]nmVariantMap, path dbus.ObjectPath) *dbus.Error {
	ssid := readSSID(conn)
	log.Infof("[SecretAgent] DeleteSecrets called: path=%s, SSID=%s", path, ssid)
	return nil
}

func (a *SecretAgent) DeleteSecrets2(path dbus.ObjectPath, setting string) *dbus.Error {
	log.Infof("[SecretAgent] DeleteSecrets2 (alternate) called: path=%s, setting=%s", path, setting)
	return nil
}

func (a *SecretAgent) CancelGetSecrets(path dbus.ObjectPath, settingName string) *dbus.Error {
	log.Infof("[SecretAgent] CancelGetSecrets called: path=%s, setting=%s", path, settingName)

	if a.prompts != nil {
		if err := a.prompts.Cancel(string(path), settingName); err != nil {
			log.Warnf("[SecretAgent] Failed to cancel prompt: %v", err)
		}
	}

	return nil
}

func (a *SecretAgent) Introspect() (string, *dbus.Error) {
	return introspectXML, nil
}

func readSSID(conn map[string]nmVariantMap) string {
	if w, ok := conn["802-11-wireless"]; ok {
		if v, ok := w["ssid"]; ok {
			if b, ok := v.Value().([]byte); ok {
				return string(b)
			}
			if s, ok := v.Value().(string); ok {
				return s
			}
		}
	}
	return ""
}

func readConnTypeAndName(conn map[string]nmVariantMap) (string, string, string) {
	var connType, name, svc string
	if c, ok := conn["connection"]; ok {
		if v, ok := c["type"]; ok {
			if s, ok2 := v.Value().(string); ok2 {
				connType = s
			}
		}
		if v, ok := c["id"]; ok {
			if s, ok2 := v.Value().(string); ok2 {
				name = s
			}
		}
	}
	if vpn, ok := conn["vpn"]; ok {
		if v, ok := vpn["service-type"]; ok {
			if s, ok2 := v.Value().(string); ok2 {
				svc = s
			}
		}
	}
	if name == "" && connType == "802-11-wireless" {
		name = readSSID(conn)
	}
	return connType, name, svc
}

func fieldsNeeded(setting string, hints []string) []string {
	switch setting {
	case "802-11-wireless-security":
		return []string{"psk"}
	case "802-1x":
		return []string{"identity", "password"}
	case "vpn":
		return hints
	default:
		return []string{}
	}
}

func reasonFromFlags(flags uint32) string {
	const (
		NM_SECRET_AGENT_GET_SECRETS_FLAG_NONE              = 0x0
		NM_SECRET_AGENT_GET_SECRETS_FLAG_ALLOW_INTERACTION = 0x1
		NM_SECRET_AGENT_GET_SECRETS_FLAG_REQUEST_NEW       = 0x2
		NM_SECRET_AGENT_GET_SECRETS_FLAG_USER_REQUESTED    = 0x4
		NM_SECRET_AGENT_GET_SECRETS_FLAG_WPS_PBC_ACTIVE    = 0x8
		NM_SECRET_AGENT_GET_SECRETS_FLAG_ONLY_SYSTEM       = 0x80000000
		NM_SECRET_AGENT_GET_SECRETS_FLAG_NO_ERRORS         = 0x40000000
	)

	if flags&NM_SECRET_AGENT_GET_SECRETS_FLAG_REQUEST_NEW != 0 {
		return "wrong-password"
	}
	if flags&NM_SECRET_AGENT_GET_SECRETS_FLAG_USER_REQUESTED != 0 {
		return "user-requested"
	}
	return "required"
}
