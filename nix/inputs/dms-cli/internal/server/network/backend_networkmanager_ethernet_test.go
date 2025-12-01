package network

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNetworkManagerBackend_GetWiredConnections_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	_, err = backend.GetWiredConnections()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestNetworkManagerBackend_GetWiredNetworkDetails_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	_, err = backend.GetWiredNetworkDetails("test-uuid")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestNetworkManagerBackend_ConnectEthernet_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	err = backend.ConnectEthernet()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestNetworkManagerBackend_DisconnectEthernet_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	err = backend.DisconnectEthernet()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestNetworkManagerBackend_ActivateWiredConnection_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	err = backend.ActivateWiredConnection("test-uuid")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}

func TestNetworkManagerBackend_ActivateWiredConnection_NotFound(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	if backend.ethernetDevice == nil {
		t.Skip("No ethernet device available")
	}

	err = backend.ActivateWiredConnection("non-existent-uuid-12345")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not found")
}

func TestNetworkManagerBackend_ListEthernetConnections_NoDevice(t *testing.T) {
	backend, err := NewNetworkManagerBackend()
	if err != nil {
		t.Skipf("NetworkManager not available: %v", err)
	}

	backend.ethernetDevice = nil
	_, err = backend.listEthernetConnections()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no ethernet device available")
}
