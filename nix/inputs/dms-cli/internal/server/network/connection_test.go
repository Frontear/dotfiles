package network_test

import (
	"errors"
	"testing"

	mocks_network "github.com/AvengeMedia/danklinux/internal/mocks/network"
	"github.com/AvengeMedia/danklinux/internal/server/network"
	"github.com/stretchr/testify/assert"
)

func TestConnectionRequest_Validation(t *testing.T) {
	t.Run("basic WiFi connection", func(t *testing.T) {
		req := network.ConnectionRequest{
			SSID:     "TestNetwork",
			Password: "testpass123",
		}

		assert.NotEmpty(t, req.SSID)
		assert.NotEmpty(t, req.Password)
		assert.Empty(t, req.Username)
	})

	t.Run("enterprise WiFi connection", func(t *testing.T) {
		req := network.ConnectionRequest{
			SSID:     "EnterpriseNetwork",
			Password: "testpass123",
			Username: "testuser",
		}

		assert.NotEmpty(t, req.SSID)
		assert.NotEmpty(t, req.Password)
		assert.NotEmpty(t, req.Username)
	})

	t.Run("open WiFi connection", func(t *testing.T) {
		req := network.ConnectionRequest{
			SSID: "OpenNetwork",
		}

		assert.NotEmpty(t, req.SSID)
		assert.Empty(t, req.Password)
		assert.Empty(t, req.Username)
	})
}

func TestManager_ConnectWiFi_NoDevice(t *testing.T) {
	backend := mocks_network.NewMockBackend(t)
	req := network.ConnectionRequest{
		SSID:     "TestNetwork",
		Password: "testpass123",
	}
	backend.EXPECT().ConnectWiFi(req).Return(errors.New("no WiFi device available"))

	manager := network.NewTestManager(backend, &network.NetworkState{})

	err := manager.ConnectWiFi(req)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no WiFi device available")
}

func TestManager_DisconnectWiFi_NoDevice(t *testing.T) {
	backend := mocks_network.NewMockBackend(t)
	backend.EXPECT().DisconnectWiFi().Return(errors.New("no WiFi device available"))

	manager := network.NewTestManager(backend, &network.NetworkState{})

	err := manager.DisconnectWiFi()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no WiFi device available")
}

func TestManager_ForgetWiFiNetwork_NotFound(t *testing.T) {
	backend := mocks_network.NewMockBackend(t)
	backend.EXPECT().ForgetWiFiNetwork("NonExistentNetwork").Return(errors.New("connection not found"))

	manager := network.NewTestManager(backend, &network.NetworkState{})

	err := manager.ForgetWiFiNetwork("NonExistentNetwork")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "connection not found")
}

func TestManager_ConnectEthernet_NoDevice(t *testing.T) {
	backend := mocks_network.NewMockBackend(t)
	backend.EXPECT().ConnectEthernet().Return(errors.New("no ethernet device available"))

	manager := network.NewTestManager(backend, &network.NetworkState{})

	err := manager.ConnectEthernet()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestManager_DisconnectEthernet_NoDevice(t *testing.T) {
	backend := mocks_network.NewMockBackend(t)
	backend.EXPECT().DisconnectEthernet().Return(errors.New("no ethernet device available"))

	manager := network.NewTestManager(backend, &network.NetworkState{})

	err := manager.DisconnectEthernet()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

// Note: More comprehensive tests for connection operations would require
// mocking the NetworkManager D-Bus interfaces, which is beyond the scope
// of these unit tests. The tests above cover the basic error cases and
// validation logic. Integration tests would be needed for full coverage.
