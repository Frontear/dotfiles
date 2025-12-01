package network

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFrequencyToChannel(t *testing.T) {
	tests := []struct {
		name      string
		frequency uint32
		channel   uint32
	}{
		{"2.4 GHz channel 1", 2412, 1},
		{"2.4 GHz channel 6", 2437, 6},
		{"2.4 GHz channel 11", 2462, 11},
		{"2.4 GHz channel 14", 2484, 14},
		{"5 GHz channel 36", 5180, 36},
		{"5 GHz channel 40", 5200, 40},
		{"5 GHz channel 165", 5825, 165},
		{"6 GHz channel 1", 5955, 1},
		{"6 GHz channel 233", 7115, 233},
		{"Unknown frequency", 1000, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := frequencyToChannel(tt.frequency)
			assert.Equal(t, tt.channel, result)
		})
	}
}

func TestSortWiFiNetworks(t *testing.T) {
	t.Run("connected network comes first", func(t *testing.T) {
		networks := []WiFiNetwork{
			{SSID: "Network1", Signal: 90, Connected: false},
			{SSID: "Network2", Signal: 80, Connected: true},
			{SSID: "Network3", Signal: 70, Connected: false},
		}

		sortWiFiNetworks(networks)

		assert.Equal(t, "Network2", networks[0].SSID)
		assert.True(t, networks[0].Connected)
	})

	t.Run("sorts by signal strength", func(t *testing.T) {
		networks := []WiFiNetwork{
			{SSID: "Weak", Signal: 40, Secured: true},
			{SSID: "Strong", Signal: 90, Secured: true},
			{SSID: "Medium", Signal: 60, Secured: true},
		}

		sortWiFiNetworks(networks)

		assert.Equal(t, "Strong", networks[0].SSID)
		assert.Equal(t, "Medium", networks[1].SSID)
		assert.Equal(t, "Weak", networks[2].SSID)
	})

	t.Run("prioritizes open networks with good signal", func(t *testing.T) {
		networks := []WiFiNetwork{
			{SSID: "SecureWeak", Signal: 40, Secured: true},
			{SSID: "OpenStrong", Signal: 60, Secured: false},
			{SSID: "SecureStrong", Signal: 90, Secured: true},
		}

		sortWiFiNetworks(networks)

		// The sorting gives priority to open networks with good signal (>= 50)
		// OpenStrong (60 signal, open) should come before SecureWeak (40 signal, secured)
		assert.Equal(t, "OpenStrong", networks[0].SSID)

		// Verify open network comes before weak secure network
		openIdx := -1
		weakSecureIdx := -1
		for i, n := range networks {
			if n.SSID == "OpenStrong" {
				openIdx = i
			}
			if n.SSID == "SecureWeak" {
				weakSecureIdx = i
			}
		}
		assert.Less(t, openIdx, weakSecureIdx, "OpenStrong should come before SecureWeak")
	})

	t.Run("prioritizes saved networks after connected", func(t *testing.T) {
		networks := []WiFiNetwork{
			{SSID: "UnsavedStrong", Signal: 95, Saved: false},
			{SSID: "SavedMedium", Signal: 60, Saved: true},
			{SSID: "SavedWeak", Signal: 50, Saved: true},
			{SSID: "UnsavedMedium", Signal: 70, Saved: false},
		}

		sortWiFiNetworks(networks)

		assert.Equal(t, "SavedMedium", networks[0].SSID)
		assert.Equal(t, "SavedWeak", networks[1].SSID)
		assert.Equal(t, "UnsavedStrong", networks[2].SSID)
		assert.Equal(t, "UnsavedMedium", networks[3].SSID)
	})
}

func TestManager_GetWiFiNetworks(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			WiFiNetworks: []WiFiNetwork{
				{SSID: "Network1", Signal: 90},
				{SSID: "Network2", Signal: 80},
			},
		},
	}

	networks := manager.GetWiFiNetworks()

	assert.Len(t, networks, 2)
	assert.Equal(t, "Network1", networks[0].SSID)
	assert.Equal(t, "Network2", networks[1].SSID)

	// Verify it's a copy, not the original
	networks[0].SSID = "Modified"
	assert.Equal(t, "Network1", manager.state.WiFiNetworks[0].SSID)
}

func TestManager_GetNetworkInfo(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			WiFiNetworks: []WiFiNetwork{
				{SSID: "Network1", Signal: 90, BSSID: "00:11:22:33:44:55"},
				{SSID: "Network2", Signal: 80, BSSID: "AA:BB:CC:DD:EE:FF"},
			},
		},
	}

	t.Run("finds existing network", func(t *testing.T) {
		network, err := manager.GetNetworkInfo("Network1")
		assert.NoError(t, err)
		assert.NotNil(t, network)
		assert.Equal(t, "Network1", network.SSID)
		assert.Equal(t, uint8(90), network.Signal)
	})

	t.Run("returns error for non-existent network", func(t *testing.T) {
		network, err := manager.GetNetworkInfo("NonExistent")
		assert.Error(t, err)
		assert.Nil(t, network)
		assert.Contains(t, err.Error(), "network not found")
	})
}
