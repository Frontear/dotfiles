//go:build distro_binary

package dms

import (
	"os/exec"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

type AppState int

const (
	StateMainMenu AppState = iota
	StateShell
	StatePluginsMenu
	StatePluginsBrowse
	StatePluginDetail
	StatePluginSearch
	StatePluginsInstalled
	StatePluginInstalledDetail
	StateAbout
)

type Model struct {
	version      string
	detector     *Detector
	dependencies []DependencyInfo
	state        AppState
	selectedItem int
	width        int
	height       int

	// Menu items
	menuItems []MenuItem

	// Window manager states
	hyprlandInstalled bool
	niriInstalled     bool

	pluginsMenuItems        []MenuItem
	selectedPluginsMenuItem int
	pluginsList             []pluginInfo
	filteredPluginsList     []pluginInfo
	selectedPluginIndex     int
	pluginsLoading          bool
	pluginsError            string
	pluginSearchQuery       string
	installedPluginsList    []pluginInfo
	selectedInstalledIndex  int
	installedPluginsLoading bool
	installedPluginsError   string
	pluginInstallStatus     map[string]bool
}

type pluginInfo struct {
	ID           string
	Name         string
	Category     string
	Author       string
	Description  string
	Repo         string
	Path         string
	Capabilities []string
	Compositors  []string
	Dependencies []string
	FirstParty   bool
}

type MenuItem struct {
	Label  string
	Action AppState
}

func NewModel(version string) Model {
	detector, _ := NewDetector()
	dependencies := detector.GetInstalledComponents()

	// Use the proper detection method for both window managers
	hyprlandInstalled, niriInstalled, err := detector.GetWindowManagerStatus()
	if err != nil {
		// Fallback to false if detection fails
		hyprlandInstalled = false
		niriInstalled = false
	}

	m := Model{
		version:             version,
		detector:            detector,
		dependencies:        dependencies,
		state:               StateMainMenu,
		selectedItem:        0,
		hyprlandInstalled:   hyprlandInstalled,
		niriInstalled:       niriInstalled,
		pluginInstallStatus: make(map[string]bool),
	}

	m.menuItems = m.buildMenuItems()
	return m
}

func (m *Model) buildMenuItems() []MenuItem {
	items := []MenuItem{}

	// Shell management
	if m.isShellRunning() {
		items = append(items, MenuItem{Label: "Terminate Shell", Action: StateShell})
	} else {
		items = append(items, MenuItem{Label: "Start Shell (Daemon)", Action: StateShell})
	}

	// Plugins management
	items = append(items, MenuItem{Label: "Plugins", Action: StatePluginsMenu})

	items = append(items, MenuItem{Label: "About", Action: StateAbout})

	return items
}

func (m *Model) buildPluginsMenuItems() []MenuItem {
	return []MenuItem{
		{Label: "Browse Plugins", Action: StatePluginsBrowse},
		{Label: "View Installed", Action: StatePluginsInstalled},
	}
}

func (m *Model) isShellRunning() bool {
	cmd := exec.Command("pgrep", "-f", "qs -c dms")
	err := cmd.Run()
	return err == nil
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case pluginsLoadedMsg:
		m.pluginsLoading = false
		if msg.err != nil {
			m.pluginsError = msg.err.Error()
		} else {
			m.pluginsList = make([]pluginInfo, len(msg.plugins))
			for i, p := range msg.plugins {
				m.pluginsList[i] = pluginInfo{
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
			m.filteredPluginsList = m.pluginsList
			m.selectedPluginIndex = 0
			m.updatePluginInstallStatus()
		}
		return m, nil
	case installedPluginsLoadedMsg:
		m.installedPluginsLoading = false
		if msg.err != nil {
			m.installedPluginsError = msg.err.Error()
		} else {
			m.installedPluginsList = make([]pluginInfo, len(msg.plugins))
			for i, p := range msg.plugins {
				m.installedPluginsList[i] = pluginInfo{
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
			m.selectedInstalledIndex = 0
		}
		return m, nil
	case pluginUninstalledMsg:
		if msg.err != nil {
			m.installedPluginsError = msg.err.Error()
			m.state = StatePluginInstalledDetail
		} else {
			m.state = StatePluginsInstalled
			m.installedPluginsLoading = true
			m.installedPluginsError = ""
			return m, loadInstalledPlugins
		}
		return m, nil
	case pluginInstalledMsg:
		if msg.err != nil {
			m.pluginsError = msg.err.Error()
		} else {
			m.pluginInstallStatus[msg.pluginName] = true
			m.pluginsError = ""
		}
		return m, nil
	case tea.KeyMsg:
		switch m.state {
		case StateMainMenu:
			return m.updateMainMenu(msg)
		case StateShell:
			return m.updateShellView(msg)
		case StatePluginsMenu:
			return m.updatePluginsMenu(msg)
		case StatePluginsBrowse:
			return m.updatePluginsBrowse(msg)
		case StatePluginDetail:
			return m.updatePluginDetail(msg)
		case StatePluginSearch:
			return m.updatePluginSearch(msg)
		case StatePluginsInstalled:
			return m.updatePluginsInstalled(msg)
		case StatePluginInstalledDetail:
			return m.updatePluginInstalledDetail(msg)
		case StateAbout:
			return m.updateAboutView(msg)
		}
	}

	return m, nil
}

func (m Model) View() string {
	switch m.state {
	case StateMainMenu:
		return m.renderMainMenu()
	case StateShell:
		return m.renderShellView()
	case StatePluginsMenu:
		return m.renderPluginsMenu()
	case StatePluginsBrowse:
		return m.renderPluginsBrowse()
	case StatePluginDetail:
		return m.renderPluginDetail()
	case StatePluginSearch:
		return m.renderPluginSearch()
	case StatePluginsInstalled:
		return m.renderPluginsInstalled()
	case StatePluginInstalledDetail:
		return m.renderPluginInstalledDetail()
	case StateAbout:
		return m.renderAboutView()
	default:
		return m.renderMainMenu()
	}
}
