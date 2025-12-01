//go:build !distro_binary

package dms

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

func (m Model) renderUpdateView() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Update Dependencies"))
	b.WriteString("\n")

	if len(m.updateDeps) == 0 {
		b.WriteString("Loading dependencies...\n")
		return b.String()
	}

	categories := m.categorizeDependencies()
	currentIndex := 0

	for _, category := range []string{"Shell", "Shared Components", "Hyprland Components", "Niri Components"} {
		deps, exists := categories[category]
		if !exists || len(deps) == 0 {
			continue
		}

		categoryStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#7060ac")).
			Bold(true).
			MarginTop(1)

		b.WriteString(categoryStyle.Render(category + ":"))
		b.WriteString("\n")

		for _, dep := range deps {
			var statusText, icon, reinstallMarker string
			var style lipgloss.Style

			if m.updateToggles[dep.Name] {
				reinstallMarker = "🔄 "
				if dep.Status == 0 {
					statusText = "Will be installed"
				} else {
					statusText = "Will be upgraded"
				}
				style = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFA500"))
			} else {
				switch dep.Status {
				case 1:
					icon = "✓"
					statusText = "Installed"
					style = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFFFFF"))
				case 0:
					icon = "○"
					statusText = "Not installed"
					style = lipgloss.NewStyle().Foreground(lipgloss.Color("#888888"))
				case 2:
					icon = "△"
					statusText = "Needs update"
					style = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFA500"))
				case 3:
					icon = "!"
					statusText = "Needs reinstall"
					style = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFA500"))
				}
			}

			line := fmt.Sprintf("%s%s%-25s %s", reinstallMarker, icon, dep.Name, statusText)

			if currentIndex == m.selectedUpdateDep {
				line = "▶ " + line
				selectedStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("#7060ac")).Bold(true)
				b.WriteString(selectedStyle.Render(line))
			} else {
				line = "  " + line
				b.WriteString(style.Render(line))
			}
			b.WriteString("\n")
			currentIndex++
		}
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888")).
		MarginTop(1)

	instructions := "↑/↓: Navigate, Space: Toggle, Enter: Update Selected, Esc: Back"
	b.WriteString(instructionStyle.Render(instructions))

	return b.String()
}

func (m Model) renderPasswordView() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Sudo Authentication"))
	b.WriteString("\n\n")

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	b.WriteString(normalStyle.Render("Package installation requires sudo privileges."))
	b.WriteString("\n")
	b.WriteString(normalStyle.Render("Please enter your password to continue:"))
	b.WriteString("\n\n")

	inputStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA"))

	maskedPassword := strings.Repeat("*", len(m.passwordInput))
	b.WriteString(inputStyle.Render("Password: " + maskedPassword))
	b.WriteString("\n")

	if m.passwordError != "" {
		errorStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FF0000"))
		b.WriteString(errorStyle.Render("✗ " + m.passwordError))
		b.WriteString("\n")
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888")).
		MarginTop(1)

	instructions := "Enter: Continue, Esc: Back, Ctrl+C: Cancel"
	b.WriteString(instructionStyle.Render(instructions))

	return b.String()
}

func (m Model) renderProgressView() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Updating Packages"))
	b.WriteString("\n\n")

	if !m.updateProgress.complete {
		progressStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#00D4AA"))

		b.WriteString(progressStyle.Render(m.updateProgress.step))
		b.WriteString("\n\n")

		progressBar := fmt.Sprintf("[%s%s] %.0f%%",
			strings.Repeat("█", int(m.updateProgress.progress*30)),
			strings.Repeat("░", 30-int(m.updateProgress.progress*30)),
			m.updateProgress.progress*100)
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("#FFFFFF")).Render(progressBar))
		b.WriteString("\n")

		if len(m.updateLogs) > 0 {
			b.WriteString("\n")
			logHeader := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888")).Render("Live Output:")
			b.WriteString(logHeader)
			b.WriteString("\n")

			maxLines := 8
			startIdx := 0
			if len(m.updateLogs) > maxLines {
				startIdx = len(m.updateLogs) - maxLines
			}

			logStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888"))
			for i := startIdx; i < len(m.updateLogs); i++ {
				if m.updateLogs[i] != "" {
					b.WriteString(logStyle.Render("  " + m.updateLogs[i]))
					b.WriteString("\n")
				}
			}
		}
	}

	if m.updateProgress.err != nil {
		errorStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FF0000"))

		b.WriteString("\n")
		b.WriteString(errorStyle.Render(fmt.Sprintf("✗ Update failed: %v", m.updateProgress.err)))
		b.WriteString("\n")

		if len(m.updateLogs) > 0 {
			b.WriteString("\n")
			logHeader := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888")).Render("Error Logs:")
			b.WriteString(logHeader)
			b.WriteString("\n")

			maxLines := 15
			startIdx := 0
			if len(m.updateLogs) > maxLines {
				startIdx = len(m.updateLogs) - maxLines
			}

			logStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888"))
			for i := startIdx; i < len(m.updateLogs); i++ {
				if m.updateLogs[i] != "" {
					b.WriteString(logStyle.Render("  " + m.updateLogs[i]))
					b.WriteString("\n")
				}
			}
		}

		b.WriteString("\n")
		instructionStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#888888"))
		b.WriteString(instructionStyle.Render("Press Esc to go back"))
	} else if m.updateProgress.complete {
		successStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#00D4AA"))

		b.WriteString("\n")
		b.WriteString(successStyle.Render("✓ Update complete!"))
		b.WriteString("\n\n")

		instructionStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#888888"))
		b.WriteString(instructionStyle.Render("Press Esc to return to main menu"))
	}

	return b.String()
}

func (m Model) getFilteredDeps() []DependencyInfo {
	categories := m.categorizeDependencies()
	var filtered []DependencyInfo

	for _, category := range []string{"Shell", "Shared Components", "Hyprland Components", "Niri Components"} {
		deps, exists := categories[category]
		if exists {
			filtered = append(filtered, deps...)
		}
	}

	return filtered
}

func (m Model) getDepAtVisualIndex(index int) *DependencyInfo {
	filtered := m.getFilteredDeps()
	if index >= 0 && index < len(filtered) {
		return &filtered[index]
	}
	return nil
}

func (m Model) renderGreeterPasswordView() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Sudo Authentication"))
	b.WriteString("\n\n")

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	b.WriteString(normalStyle.Render("Greeter installation requires sudo privileges."))
	b.WriteString("\n")
	b.WriteString(normalStyle.Render("Please enter your password to continue:"))
	b.WriteString("\n\n")

	inputStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA"))

	maskedPassword := strings.Repeat("*", len(m.greeterPasswordInput))
	b.WriteString(inputStyle.Render("Password: " + maskedPassword))
	b.WriteString("\n")

	if m.greeterPasswordError != "" {
		errorStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FF0000"))
		b.WriteString(errorStyle.Render("✗ " + m.greeterPasswordError))
		b.WriteString("\n")
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888")).
		MarginTop(1)

	instructions := "Enter: Continue, Esc: Back, Ctrl+C: Cancel"
	b.WriteString(instructionStyle.Render(instructions))

	return b.String()
}

func (m Model) renderGreeterCompositorSelect() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Select Compositor"))
	b.WriteString("\n\n")

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	b.WriteString(normalStyle.Render("Multiple compositors detected. Choose which one to use for the greeter:"))
	b.WriteString("\n\n")

	selectedStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA")).
		Bold(true)

	for i, comp := range m.greeterCompositors {
		if i == m.greeterSelectedComp {
			b.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s", comp)))
		} else {
			b.WriteString(normalStyle.Render(fmt.Sprintf("  %s", comp)))
		}
		b.WriteString("\n")
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888")).
		MarginTop(1)

	instructions := "↑/↓: Navigate, Enter: Select, Esc: Back"
	b.WriteString(instructionStyle.Render(instructions))

	return b.String()
}

func (m Model) renderGreeterMenu() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Greeter Management"))
	b.WriteString("\n")

	greeterMenuItems := []string{"Install Greeter"}

	selectedStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#00D4AA")).
		Bold(true)

	normalStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF"))

	for i, item := range greeterMenuItems {
		if i == m.selectedGreeterItem {
			b.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s", item)))
		} else {
			b.WriteString(normalStyle.Render(fmt.Sprintf("  %s", item)))
		}
		b.WriteString("\n")
	}

	b.WriteString("\n")
	instructionStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#888888")).
		MarginTop(1)

	instructions := "↑/↓: Navigate, Enter: Select, Esc: Back"
	b.WriteString(instructionStyle.Render(instructions))

	return b.String()
}

func (m Model) renderGreeterInstalling() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	headerStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Bold(true).
		MarginBottom(1)

	b.WriteString(headerStyle.Render("Installing Greeter"))
	b.WriteString("\n\n")

	if !m.greeterProgress.complete {
		progressStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#00D4AA"))

		b.WriteString(progressStyle.Render(m.greeterProgress.step))
		b.WriteString("\n\n")

		if len(m.greeterLogs) > 0 {
			b.WriteString("\n")
			logHeader := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888")).Render("Output:")
			b.WriteString(logHeader)
			b.WriteString("\n")

			maxLines := 10
			startIdx := 0
			if len(m.greeterLogs) > maxLines {
				startIdx = len(m.greeterLogs) - maxLines
			}

			logStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("#888888"))
			for i := startIdx; i < len(m.greeterLogs); i++ {
				if m.greeterLogs[i] != "" {
					b.WriteString(logStyle.Render("  " + m.greeterLogs[i]))
					b.WriteString("\n")
				}
			}
		}
	}

	if m.greeterProgress.err != nil {
		errorStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FF0000"))

		b.WriteString("\n")
		b.WriteString(errorStyle.Render(fmt.Sprintf("✗ Installation failed: %v", m.greeterProgress.err)))
		b.WriteString("\n\n")

		instructionStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#888888"))
		b.WriteString(instructionStyle.Render("Press Esc to go back"))
	} else if m.greeterProgress.complete {
		successStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#00D4AA"))

		b.WriteString("\n")
		b.WriteString(successStyle.Render("✓ Greeter installation complete!"))
		b.WriteString("\n\n")

		normalStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFFFFF"))

		b.WriteString(normalStyle.Render("To test the greeter, run:"))
		b.WriteString("\n")
		b.WriteString(normalStyle.Render("  sudo systemctl start greetd"))
		b.WriteString("\n\n")
		b.WriteString(normalStyle.Render("To enable on boot, run:"))
		b.WriteString("\n")
		b.WriteString(normalStyle.Render("  sudo systemctl enable --now greetd"))
		b.WriteString("\n\n")

		instructionStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("#888888"))
		b.WriteString(instructionStyle.Render("Press Esc to return to main menu"))
	}

	return b.String()
}

func (m Model) categorizeDependencies() map[string][]DependencyInfo {
	categories := map[string][]DependencyInfo{
		"Shell":               {},
		"Shared Components":   {},
		"Hyprland Components": {},
		"Niri Components":     {},
	}

	excludeList := map[string]bool{
		"git":                         true,
		"polkit-agent":                true,
		"jq":                          true,
		"xdg-desktop-portal":          true,
		"xdg-desktop-portal-wlr":      true,
		"xdg-desktop-portal-hyprland": true,
		"xdg-desktop-portal-gtk":      true,
	}

	for _, dep := range m.updateDeps {
		if excludeList[dep.Name] {
			continue
		}

		switch dep.Name {
		case "dms (DankMaterialShell)", "quickshell":
			categories["Shell"] = append(categories["Shell"], dep)
		case "hyprland", "grim", "slurp", "hyprctl", "grimblast":
			categories["Hyprland Components"] = append(categories["Hyprland Components"], dep)
		case "niri":
			categories["Niri Components"] = append(categories["Niri Components"], dep)
		case "kitty", "alacritty", "ghostty", "hyprpicker":
			categories["Shared Components"] = append(categories["Shared Components"], dep)
		default:
			categories["Shared Components"] = append(categories["Shared Components"], dep)
		}
	}

	return categories
}
