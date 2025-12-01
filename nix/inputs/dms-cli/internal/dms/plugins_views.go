package dms

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

func (m Model) renderPluginsMenu() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	selectedStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA")).
		Bold(true)

	b.WriteString(titleStyle.Render("Plugins"))
	b.WriteString("\n\n")

	for i, item := range m.pluginsMenuItems {
		if i == m.selectedPluginsMenuItem {
			b.WriteString(selectedStyle.Render(fmt.Sprintf("→ %s", item.Label)))
		} else {
			b.WriteString(normalStyle.Render(fmt.Sprintf("  %s", item.Label)))
		}
		b.WriteString("\n")
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))
	b.WriteString(instructionStyle.Render("↑/↓: Navigate | Enter: Select | Esc: Back | q: Quit"))

	return b.String()
}

func (m Model) renderPluginsBrowse() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	errorStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FF0000"))

	selectedStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA")).
		Bold(true)

	b.WriteString(titleStyle.Render("Browse Plugins"))
	b.WriteString("\n\n")

	if m.pluginsLoading {
		b.WriteString(normalStyle.Render("Fetching plugins from registry..."))
	} else if m.pluginsError != "" {
		b.WriteString(errorStyle.Render(fmt.Sprintf("Error: %s", m.pluginsError)))
	} else if len(m.filteredPluginsList) == 0 {
		if m.pluginSearchQuery != "" {
			b.WriteString(normalStyle.Render(fmt.Sprintf("No plugins match '%s'", m.pluginSearchQuery)))
		} else {
			b.WriteString(normalStyle.Render("No plugins found in registry."))
		}
	} else {
		installedStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#888888"))

		for i, plugin := range m.filteredPluginsList {
			installed := m.pluginInstallStatus[plugin.Name]
			installMarker := ""
			if installed {
				installMarker = " [Installed]"
			}

			if i == m.selectedPluginIndex {
				b.WriteString(selectedStyle.Render(fmt.Sprintf("→ %s", plugin.Name)))
				if installed {
					b.WriteString(installedStyle.Render(installMarker))
				}
			} else {
				b.WriteString(normalStyle.Render(fmt.Sprintf("  %s", plugin.Name)))
				if installed {
					b.WriteString(installedStyle.Render(installMarker))
				}
			}
			b.WriteString("\n")
		}
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))

	if m.pluginsLoading || m.pluginsError != "" {
		b.WriteString(instructionStyle.Render("Esc: Back | q: Quit"))
	} else {
		b.WriteString(instructionStyle.Render("↑/↓: Navigate | Enter: View/Install | /: Search | Esc: Back | q: Quit"))
	}

	return b.String()
}

func (m Model) renderPluginDetail() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	labelStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))

	if m.selectedPluginIndex >= len(m.filteredPluginsList) {
		return "No plugin selected"
	}

	plugin := m.filteredPluginsList[m.selectedPluginIndex]

	b.WriteString(titleStyle.Render(plugin.Name))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("ID: "))
	b.WriteString(normalStyle.Render(plugin.ID))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Category: "))
	b.WriteString(normalStyle.Render(plugin.Category))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Author: "))
	b.WriteString(normalStyle.Render(plugin.Author))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Description:"))
	b.WriteString("\n")
	wrapped := wrapText(plugin.Description, 60)
	b.WriteString(normalStyle.Render(wrapped))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Repository: "))
	b.WriteString(normalStyle.Render(plugin.Repo))
	b.WriteString("\n\n")

	if len(plugin.Capabilities) > 0 {
		b.WriteString(labelStyle.Render("Capabilities: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Capabilities, ", ")))
		b.WriteString("\n\n")
	}

	if len(plugin.Compositors) > 0 {
		b.WriteString(labelStyle.Render("Compositors: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Compositors, ", ")))
		b.WriteString("\n\n")
	}

	if len(plugin.Dependencies) > 0 {
		b.WriteString(labelStyle.Render("Dependencies: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Dependencies, ", ")))
		b.WriteString("\n\n")
	}

	installed := m.pluginInstallStatus[plugin.Name]
	if installed {
		b.WriteString(labelStyle.Render("Status: "))
		installedStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#00D4AA"))
		b.WriteString(installedStyle.Render("Installed"))
		b.WriteString("\n\n")
	}

	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))

	if installed {
		b.WriteString(instructionStyle.Render("Esc: Back | q: Quit"))
	} else {
		b.WriteString(instructionStyle.Render("i: Install | Esc: Back | q: Quit"))
	}

	return b.String()
}

func (m Model) renderPluginSearch() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	b.WriteString(titleStyle.Render("Search Plugins"))
	b.WriteString("\n\n")

	b.WriteString(normalStyle.Render("Query: "))
	b.WriteString(titleStyle.Render(m.pluginSearchQuery + "▌"))
	b.WriteString("\n\n")

	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))
	b.WriteString(instructionStyle.Render("Enter: Search | Esc: Cancel"))

	return b.String()
}

func (m Model) renderPluginsInstalled() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	errorStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FF0000"))

	selectedStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA")).
		Bold(true)

	b.WriteString(titleStyle.Render("Installed Plugins"))
	b.WriteString("\n\n")

	if m.installedPluginsLoading {
		b.WriteString(normalStyle.Render("Loading installed plugins..."))
	} else if m.installedPluginsError != "" {
		b.WriteString(errorStyle.Render(fmt.Sprintf("Error: %s", m.installedPluginsError)))
	} else if len(m.installedPluginsList) == 0 {
		b.WriteString(normalStyle.Render("No plugins installed."))
	} else {
		for i, plugin := range m.installedPluginsList {
			if i == m.selectedInstalledIndex {
				b.WriteString(selectedStyle.Render(fmt.Sprintf("→ %s", plugin.Name)))
			} else {
				b.WriteString(normalStyle.Render(fmt.Sprintf("  %s", plugin.Name)))
			}
			b.WriteString("\n")
		}
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))

	if m.installedPluginsLoading || m.installedPluginsError != "" {
		b.WriteString(instructionStyle.Render("Esc: Back | q: Quit"))
	} else {
		b.WriteString(instructionStyle.Render("↑/↓: Navigate | Enter: Details | Esc: Back | q: Quit"))
	}

	return b.String()
}

func (m Model) renderPluginInstalledDetail() string {
	var b strings.Builder

	titleStyle := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#00D4AA"))

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	labelStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))

	errorStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FF0000"))

	if m.selectedInstalledIndex >= len(m.installedPluginsList) {
		return "No plugin selected"
	}

	plugin := m.installedPluginsList[m.selectedInstalledIndex]

	b.WriteString(titleStyle.Render(plugin.Name))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("ID: "))
	b.WriteString(normalStyle.Render(plugin.ID))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Category: "))
	b.WriteString(normalStyle.Render(plugin.Category))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Author: "))
	b.WriteString(normalStyle.Render(plugin.Author))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Description:"))
	b.WriteString("\n")
	wrapped := wrapText(plugin.Description, 60)
	b.WriteString(normalStyle.Render(wrapped))
	b.WriteString("\n\n")

	b.WriteString(labelStyle.Render("Repository: "))
	b.WriteString(normalStyle.Render(plugin.Repo))
	b.WriteString("\n\n")

	if len(plugin.Capabilities) > 0 {
		b.WriteString(labelStyle.Render("Capabilities: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Capabilities, ", ")))
		b.WriteString("\n\n")
	}

	if len(plugin.Compositors) > 0 {
		b.WriteString(labelStyle.Render("Compositors: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Compositors, ", ")))
		b.WriteString("\n\n")
	}

	if len(plugin.Dependencies) > 0 {
		b.WriteString(labelStyle.Render("Dependencies: "))
		b.WriteString(normalStyle.Render(strings.Join(plugin.Dependencies, ", ")))
		b.WriteString("\n\n")
	}

	if m.installedPluginsError != "" {
		b.WriteString(errorStyle.Render(fmt.Sprintf("Error: %s", m.installedPluginsError)))
		b.WriteString("\n\n")
	}

	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888"))
	b.WriteString(instructionStyle.Render("u: Uninstall | Esc: Back | q: Quit"))

	return b.String()
}

func wrapText(text string, width int) string {
	words := strings.Fields(text)
	if len(words) == 0 {
		return text
	}

	var lines []string
	currentLine := words[0]

	for _, word := range words[1:] {
		if len(currentLine)+1+len(word) <= width {
			currentLine += " " + word
		} else {
			lines = append(lines, currentLine)
			currentLine = word
		}
	}
	lines = append(lines, currentLine)

	return strings.Join(lines, "\n")
}
