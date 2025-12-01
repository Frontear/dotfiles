package network

import "sort"

func frequencyToChannel(freq uint32) uint32 {
	if freq >= 2412 && freq <= 2484 {
		if freq == 2484 {
			return 14
		}
		return (freq-2412)/5 + 1
	}

	if freq >= 5170 && freq <= 5825 {
		return (freq-5170)/5 + 34
	}

	if freq >= 5955 && freq <= 7115 {
		return (freq-5955)/5 + 1
	}

	return 0
}

func sortWiFiNetworks(networks []WiFiNetwork) {
	sort.Slice(networks, func(i, j int) bool {
		if networks[i].Connected && !networks[j].Connected {
			return true
		}
		if !networks[i].Connected && networks[j].Connected {
			return false
		}

		if networks[i].Saved && !networks[j].Saved {
			return true
		}
		if !networks[i].Saved && networks[j].Saved {
			return false
		}

		if !networks[i].Secured && networks[j].Secured {
			if networks[i].Signal >= 50 {
				return true
			}
		}
		if networks[i].Secured && !networks[j].Secured {
			if networks[j].Signal >= 50 {
				return false
			}
		}

		return networks[i].Signal > networks[j].Signal
	})
}
