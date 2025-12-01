package dms

import (
	"strings"

	"github.com/AvengeMedia/danklinux/internal/plugins"
	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) updatePluginsMenu(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StateMainMenu
	case "up", "k":
		if m.selectedPluginsMenuItem > 0 {
			m.selectedPluginsMenuItem--
		}
	case "down", "j":
		if m.selectedPluginsMenuItem < len(m.pluginsMenuItems)-1 {
			m.selectedPluginsMenuItem++
		}
	case "enter", " ":
		if m.selectedPluginsMenuItem < len(m.pluginsMenuItems) {
			selectedAction := m.pluginsMenuItems[m.selectedPluginsMenuItem].Action
			switch selectedAction {
			case StatePluginsBrowse:
				m.state = StatePluginsBrowse
				m.pluginsLoading = true
				m.pluginsError = ""
				m.pluginsList = nil
				return m, loadPlugins
			case StatePluginsInstalled:
				m.state = StatePluginsInstalled
				m.installedPluginsLoading = true
				m.installedPluginsError = ""
				m.installedPluginsList = nil
				return m, loadInstalledPlugins
			}
		}
	}
	return m, nil
}

func (m Model) updatePluginsBrowse(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StatePluginsMenu
		m.pluginSearchQuery = ""
		m.filteredPluginsList = m.pluginsList
		m.selectedPluginIndex = 0
	case "up", "k":
		if m.selectedPluginIndex > 0 {
			m.selectedPluginIndex--
		}
	case "down", "j":
		if m.selectedPluginIndex < len(m.filteredPluginsList)-1 {
			m.selectedPluginIndex++
		}
	case "enter", " ":
		if m.selectedPluginIndex < len(m.filteredPluginsList) {
			m.state = StatePluginDetail
		}
	case "/":
		m.state = StatePluginSearch
		m.pluginSearchQuery = ""
	}
	return m, nil
}

func (m Model) updatePluginDetail(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StatePluginsBrowse
	case "i":
		if m.selectedPluginIndex < len(m.filteredPluginsList) {
			plugin := m.filteredPluginsList[m.selectedPluginIndex]
			installed := m.pluginInstallStatus[plugin.Name]
			if !installed {
				return m, installPlugin(plugin)
			}
		}
	}
	return m, nil
}

func (m Model) updatePluginSearch(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c":
		return m, tea.Quit
	case "esc":
		m.state = StatePluginsBrowse
		m.pluginSearchQuery = ""
		m.filteredPluginsList = m.pluginsList
		m.selectedPluginIndex = 0
	case "enter":
		m.state = StatePluginsBrowse
		m.filterPlugins()
	case "backspace":
		if len(m.pluginSearchQuery) > 0 {
			m.pluginSearchQuery = m.pluginSearchQuery[:len(m.pluginSearchQuery)-1]
		}
	default:
		if len(msg.String()) == 1 {
			m.pluginSearchQuery += msg.String()
		}
	}
	return m, nil
}

func (m *Model) filterPlugins() {
	if m.pluginSearchQuery == "" {
		m.filteredPluginsList = m.pluginsList
		m.selectedPluginIndex = 0
		return
	}

	rawPlugins := make([]plugins.Plugin, len(m.pluginsList))
	for i, p := range m.pluginsList {
		rawPlugins[i] = plugins.Plugin{
			ID:           p.ID,
			Name:         p.Name,
			Category:     p.Category,
			Author:       p.Author,
			Description:  p.Description,
			Repo:         p.Repo,
			Path:         p.Path,
			Capabilities: p.Capabilities,
			Compositors:  p.Compositors,
			Dependencies: p.Dependencies,
		}
	}

	searchResults := plugins.FuzzySearch(m.pluginSearchQuery, rawPlugins)
	searchResults = plugins.SortByFirstParty(searchResults)

	filtered := make([]pluginInfo, len(searchResults))
	for i, p := range searchResults {
		filtered[i] = pluginInfo{
			ID:           p.ID,
			Name:         p.Name,
			Category:     p.Category,
			Author:       p.Author,
			Description:  p.Description,
			Repo:         p.Repo,
			Path:         p.Path,
			Capabilities: p.Capabilities,
			Compositors:  p.Compositors,
			Dependencies: p.Dependencies,
			FirstParty:   strings.HasPrefix(p.Repo, "https://github.com/AvengeMedia"),
		}
	}

	m.filteredPluginsList = filtered
	m.selectedPluginIndex = 0
}

type pluginsLoadedMsg struct {
	plugins []plugins.Plugin
	err     error
}

func loadPlugins() tea.Msg {
	registry, err := plugins.NewRegistry()
	if err != nil {
		return pluginsLoadedMsg{err: err}
	}

	pluginList, err := registry.List()
	if err != nil {
		return pluginsLoadedMsg{err: err}
	}

	return pluginsLoadedMsg{plugins: pluginList}
}

func (m *Model) updatePluginInstallStatus() {
	manager, err := plugins.NewManager()
	if err != nil {
		return
	}

	for _, plugin := range m.pluginsList {
		p := plugins.Plugin{ID: plugin.ID}
		installed, err := manager.IsInstalled(p)
		if err == nil {
			m.pluginInstallStatus[plugin.Name] = installed
		}
	}
}

func (m Model) updatePluginsInstalled(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StatePluginsMenu
	case "up", "k":
		if m.selectedInstalledIndex > 0 {
			m.selectedInstalledIndex--
		}
	case "down", "j":
		if m.selectedInstalledIndex < len(m.installedPluginsList)-1 {
			m.selectedInstalledIndex++
		}
	case "enter", " ":
		if m.selectedInstalledIndex < len(m.installedPluginsList) {
			m.state = StatePluginInstalledDetail
		}
	}
	return m, nil
}

func (m Model) updatePluginInstalledDetail(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StatePluginsInstalled
	case "u":
		if m.selectedInstalledIndex < len(m.installedPluginsList) {
			plugin := m.installedPluginsList[m.selectedInstalledIndex]
			return m, uninstallPlugin(plugin)
		}
	}
	return m, nil
}

type installedPluginsLoadedMsg struct {
	plugins []plugins.Plugin
	err     error
}

type pluginUninstalledMsg struct {
	pluginName string
	err        error
}

type pluginInstalledMsg struct {
	pluginName string
	err        error
}

func loadInstalledPlugins() tea.Msg {
	manager, err := plugins.NewManager()
	if err != nil {
		return installedPluginsLoadedMsg{err: err}
	}

	registry, err := plugins.NewRegistry()
	if err != nil {
		return installedPluginsLoadedMsg{err: err}
	}

	installedNames, err := manager.ListInstalled()
	if err != nil {
		return installedPluginsLoadedMsg{err: err}
	}

	allPlugins, err := registry.List()
	if err != nil {
		return installedPluginsLoadedMsg{err: err}
	}

	var installed []plugins.Plugin
	for _, id := range installedNames {
		for _, p := range allPlugins {
			if p.ID == id {
				installed = append(installed, p)
				break
			}
		}
	}

	installed = plugins.SortByFirstParty(installed)

	return installedPluginsLoadedMsg{plugins: installed}
}

func installPlugin(plugin pluginInfo) tea.Cmd {
	return func() tea.Msg {
		manager, err := plugins.NewManager()
		if err != nil {
			return pluginInstalledMsg{pluginName: plugin.Name, err: err}
		}

		p := plugins.Plugin{
			ID:           plugin.ID,
			Name:         plugin.Name,
			Category:     plugin.Category,
			Author:       plugin.Author,
			Description:  plugin.Description,
			Repo:         plugin.Repo,
			Path:         plugin.Path,
			Capabilities: plugin.Capabilities,
			Compositors:  plugin.Compositors,
			Dependencies: plugin.Dependencies,
		}

		if err := manager.Install(p); err != nil {
			return pluginInstalledMsg{pluginName: plugin.Name, err: err}
		}

		return pluginInstalledMsg{pluginName: plugin.Name}
	}
}

func uninstallPlugin(plugin pluginInfo) tea.Cmd {
	return func() tea.Msg {
		manager, err := plugins.NewManager()
		if err != nil {
			return pluginUninstalledMsg{pluginName: plugin.Name, err: err}
		}

		p := plugins.Plugin{
			ID:           plugin.ID,
			Name:         plugin.Name,
			Category:     plugin.Category,
			Author:       plugin.Author,
			Description:  plugin.Description,
			Repo:         plugin.Repo,
			Path:         plugin.Path,
			Capabilities: plugin.Capabilities,
			Compositors:  plugin.Compositors,
			Dependencies: plugin.Dependencies,
		}

		if err := manager.Uninstall(p); err != nil {
			return pluginUninstalledMsg{pluginName: plugin.Name, err: err}
		}

		return pluginUninstalledMsg{pluginName: plugin.Name}
	}
}
