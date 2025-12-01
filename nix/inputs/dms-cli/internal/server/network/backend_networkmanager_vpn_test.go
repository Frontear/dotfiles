package network

import (
	"testing"

	mock_gonetworkmanager "github.com/AvengeMedia/danklinux/internal/mocks/github.com/Wifx/gonetworkmanager/v2"
	"github.com/Wifx/gonetworkmanager/v2"
	"github.com/stretchr/testify/assert"
)

func TestNetworkManagerBackend_ListVPNProfiles(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)
	mockSettings := mock_gonetworkmanager.NewMockSettings(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)
	backend.settings = mockSettings

	mockSettings.EXPECT().ListConnections().Return([]gonetworkmanager.Connection{}, nil)

	profiles, err := backend.ListVPNProfiles()
	assert.NoError(t, err)
	assert.Empty(t, profiles)
}

func TestNetworkManagerBackend_ListActiveVPN(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	mockNM.EXPECT().GetPropertyActiveConnections().Return([]gonetworkmanager.ActiveConnection{}, nil)

	active, err := backend.ListActiveVPN()
	assert.NoError(t, err)
	assert.Empty(t, active)
}

func TestNetworkManagerBackend_ConnectVPN_NotFound(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)
	mockSettings := mock_gonetworkmanager.NewMockSettings(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)
	backend.settings = mockSettings

	mockSettings.EXPECT().ListConnections().Return([]gonetworkmanager.Connection{}, nil)

	err = backend.ConnectVPN("non-existent-vpn-12345", false)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not found")
}

func TestNetworkManagerBackend_ConnectVPN_SingleActive_NoActiveVPN(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)
	mockSettings := mock_gonetworkmanager.NewMockSettings(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)
	backend.settings = mockSettings

	mockSettings.EXPECT().ListConnections().Return([]gonetworkmanager.Connection{}, nil)
	mockNM.EXPECT().GetPropertyActiveConnections().Return([]gonetworkmanager.ActiveConnection{}, nil)

	err = backend.ConnectVPN("non-existent-vpn-12345", true)
	assert.Error(t, err)
}

func TestNetworkManagerBackend_DisconnectVPN_NotActive(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	mockNM.EXPECT().GetPropertyActiveConnections().Return([]gonetworkmanager.ActiveConnection{}, nil)

	err = backend.DisconnectVPN("non-existent-vpn-12345")
	assert.Error(t, err)
}

func TestNetworkManagerBackend_DisconnectAllVPN(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	mockNM.EXPECT().GetPropertyActiveConnections().Return([]gonetworkmanager.ActiveConnection{}, nil)

	err = backend.DisconnectAllVPN()
	assert.NoError(t, err)
}

func TestNetworkManagerBackend_ClearVPNCredentials_NotFound(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)
	mockSettings := mock_gonetworkmanager.NewMockSettings(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)
	backend.settings = mockSettings

	mockSettings.EXPECT().ListConnections().Return([]gonetworkmanager.Connection{}, nil)

	err = backend.ClearVPNCredentials("non-existent-vpn-12345")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not found")
}

func TestNetworkManagerBackend_UpdateVPNConnectionState_NotConnecting(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	backend.stateMutex.Lock()
	backend.state.IsConnectingVPN = false
	backend.state.ConnectingVPNUUID = ""
	backend.stateMutex.Unlock()

	assert.NotPanics(t, func() {
		backend.updateVPNConnectionState()
	})
}

func TestNetworkManagerBackend_UpdateVPNConnectionState_EmptyUUID(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	backend.stateMutex.Lock()
	backend.state.IsConnectingVPN = true
	backend.state.ConnectingVPNUUID = ""
	backend.stateMutex.Unlock()

	assert.NotPanics(t, func() {
		backend.updateVPNConnectionState()
	})
}
