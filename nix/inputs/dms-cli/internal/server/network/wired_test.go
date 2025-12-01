package network

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestManager_GetWiredConfigs(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			EthernetConnected: true,
			WiredConnections: []WiredConnection{
				{ID: "Test", IsActive: true},
			},
		},
	}

	configs := manager.GetWiredConfigs()

	assert.Len(t, configs, 1)
	assert.Equal(t, "Test", configs[0].ID)
}
