package plugins

import (
	"sort"
	"strings"
)

func SortPluginInfoByFirstParty(pluginInfos []PluginInfo) {
	sort.SliceStable(pluginInfos, func(i, j int) bool {
		isFirstPartyI := strings.HasPrefix(pluginInfos[i].Repo, "https://github.com/AvengeMedia")
		isFirstPartyJ := strings.HasPrefix(pluginInfos[j].Repo, "https://github.com/AvengeMedia")
		if isFirstPartyI != isFirstPartyJ {
			return isFirstPartyI
		}
		return false
	})
}
