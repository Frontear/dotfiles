package network

import (
	"testing"

	"github.com/AvengeMedia/danklinux/internal/errdefs"
	mock_gonetworkmanager "github.com/AvengeMedia/danklinux/internal/mocks/github.com/Wifx/gonetworkmanager/v2"
	"github.com/Wifx/gonetworkmanager/v2"
	"github.com/stretchr/testify/assert"
)

func TestNetworkManagerBackend_UpdatePrimaryConnection(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	mockNM.EXPECT().GetPropertyActiveConnections().Return([]gonetworkmanager.ActiveConnection{}, nil)
	mockNM.EXPECT().GetPropertyPrimaryConnection().Return(nil, nil)

	err = backend.updatePrimaryConnection()
	assert.NoError(t, err)
}

func TestNetworkManagerBackend_UpdateEthernetState_NoDevice(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	backend.ethernetDevice = nil
	err = backend.updateEthernetState()
	assert.NoError(t, err)
}

func TestNetworkManagerBackend_UpdateWiFiState_NoDevice(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	backend.wifiDevice = nil
	err = backend.updateWiFiState()
	assert.NoError(t, err)
}

func TestNetworkManagerBackend_ClassifyNMStateReason(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	testCases := []struct {
		reason   uint32
		expected string
	}{
		{NmDeviceStateReasonWrongPassword, errdefs.ErrBadCredentials},
		{NmDeviceStateReasonNoSecrets, errdefs.ErrUserCanceled},
		{NmDeviceStateReasonSupplicantTimeout, errdefs.ErrBadCredentials},
		{NmDeviceStateReasonDhcpClientFailed, errdefs.ErrDhcpTimeout},
		{NmDeviceStateReasonNoSsid, errdefs.ErrNoSuchSSID},
		{999, errdefs.ErrConnectionFailed},
	}

	for _, tc := range testCases {
		result := backend.classifyNMStateReason(tc.reason)
		assert.Equal(t, tc.expected, result)
	}
}

func TestNetworkManagerBackend_GetDeviceIP_NoConfig(t *testing.T) {
	mockNM := mock_gonetworkmanager.NewMockNetworkManager(t)
	mockDevice := mock_gonetworkmanager.NewMockDevice(t)

	backend, err := NewNetworkManagerBackend(mockNM)
	assert.NoError(t, err)

	mockDevice.EXPECT().GetPropertyIP4Config().Return(nil, nil)

	ip := backend.getDeviceIP(mockDevice)
	assert.Empty(t, ip)
}
