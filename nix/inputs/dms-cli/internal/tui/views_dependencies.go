package tui

import (
	"context"
	"fmt"
	"strings"

	"github.com/AvengeMedia/danklinux/internal/deps"
	"github.com/AvengeMedia/danklinux/internal/distros"
	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) viewDetectingDeps() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	title := m.styles.Title.Render("Detecting Dependencies")
	b.WriteString(title)
	b.WriteString("\n\n")

	spinner := m.spinner.View()
	status := m.styles.Normal.Render("Scanning system for existing packages and configurations...")
	b.WriteString(fmt.Sprintf("%s %s", spinner, status))

	return b.String()
}

func (m Model) viewDependencyReview() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n")

	title := m.styles.Title.Render("Dependency Review")
	b.WriteString(title)
	b.WriteString("\n\n")

	if len(m.dependencies) > 0 {
		for i, dep := range m.dependencies {
			var status string
			var reinstallMarker string
			var variantMarker string

			isDMS := dep.Name == "dms (DankMaterialShell)"

			if dep.CanToggle && dep.Variant == deps.VariantGit {
				variantMarker = "[git] "
			}

			if m.reinstallItems[dep.Name] {
				reinstallMarker = "🔄 "
				status = m.styles.Warning.Render("Will reinstall")
			} else if isDMS {
				reinstallMarker = "⚡ "
				switch dep.Status {
				case deps.StatusInstalled:
					status = m.styles.Success.Render("✓ Required (installed)")
				case deps.StatusMissing:
					status = m.styles.Warning.Render("○ Required (will install)")
				case deps.StatusNeedsUpdate:
					status = m.styles.Warning.Render("△ Required (needs update)")
				case deps.StatusNeedsReinstall:
					status = m.styles.Error.Render("! Required (needs reinstall)")
				}
			} else {
				switch dep.Status {
				case deps.StatusInstalled:
					status = m.styles.Success.Render("✓ Already Installed")
				case deps.StatusMissing:
					status = m.styles.Warning.Render("○ Will be installed")
				case deps.StatusNeedsUpdate:
					status = m.styles.Warning.Render("△ Needs update")
				case deps.StatusNeedsReinstall:
					status = m.styles.Error.Render("! Needs reinstall")
				}
			}

			var line string
			if i == m.selectedDep {
				line = fmt.Sprintf("▶ %s%s%-25s %s", reinstallMarker, variantMarker, dep.Name, status)
				if dep.Version != "" {
					line += fmt.Sprintf(" (%s)", dep.Version)
				}
				line = m.styles.SelectedOption.Render(line)
			} else {
				line = fmt.Sprintf("  %s%s%-25s %s", reinstallMarker, variantMarker, dep.Name, status)
				if dep.Version != "" {
					line += fmt.Sprintf(" (%s)", dep.Version)
				}
				line = m.styles.Normal.Render(line)
			}

			b.WriteString(line)
			b.WriteString("\n")
		}
	}

	b.WriteString("\n")
	help := m.styles.Subtle.Render("↑/↓: Navigate, Space: Toggle reinstall, G: Toggle stable/git, Enter: Continue")
	b.WriteString(help)

	return b.String()
}

func (m Model) updateDetectingDepsState(msg tea.Msg) (tea.Model, tea.Cmd) {
	if depsMsg, ok := msg.(depsDetectedMsg); ok {
		m.isLoading = false
		if depsMsg.err != nil {
			m.err = depsMsg.err
			m.state = StateError
		} else {
			m.dependencies = depsMsg.deps
			m.state = StateDependencyReview
		}
		return m, m.listenForLogs()
	}
	return m, m.listenForLogs()
}

func (m Model) updateDependencyReviewState(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "up":
			if m.selectedDep > 0 {
				m.selectedDep--
			}
		case "down":
			if m.selectedDep < len(m.dependencies)-1 {
				m.selectedDep++
			}
		case " ":
			if len(m.dependencies) > 0 {
				depName := m.dependencies[m.selectedDep].Name

				if m.dependencies[m.selectedDep].Status == deps.StatusInstalled ||
					m.dependencies[m.selectedDep].Status == deps.StatusNeedsReinstall {
					m.reinstallItems[depName] = !m.reinstallItems[depName]
				}
			}
		case "g", "G":
			if len(m.dependencies) > 0 && m.dependencies[m.selectedDep].CanToggle {
				if m.dependencies[m.selectedDep].Variant == deps.VariantStable {
					m.dependencies[m.selectedDep].Variant = deps.VariantGit
				} else {
					m.dependencies[m.selectedDep].Variant = deps.VariantStable
				}
			}
		case "enter":
			// Check if fingerprint is enabled
			if checkFingerprintEnabled() {
				m.state = StateAuthMethodChoice
				m.selectedConfig = 0 // Default to fingerprint
				return m, nil
			} else {
				m.state = StatePasswordPrompt
				m.passwordInput.Focus()
				return m, nil
			}
		case "esc":
			m.state = StateSelectWindowManager
			return m, nil
		}
	}
	return m, m.listenForLogs()
}

func (m Model) installPackages() tea.Cmd {
	return func() tea.Msg {
		if m.osInfo == nil {
			return packageInstallProgressMsg{
				progress:   0.0,
				step:       "Error: OS info not available",
				isComplete: true,
			}
		}

		installer, err := distros.NewPackageInstaller(m.osInfo.Distribution.ID, m.logChan)
		if err != nil {
			return packageInstallProgressMsg{
				progress:   0.0,
				step:       fmt.Sprintf("Error: %s", err.Error()),
				isComplete: true,
			}
		}

		// Convert TUI selection to deps enum
		var wm deps.WindowManager
		if m.selectedWM == 0 {
			wm = deps.WindowManagerNiri
		} else {
			wm = deps.WindowManagerHyprland
		}

		installerProgressChan := make(chan distros.InstallProgressMsg, 100)

		go func() {
			defer close(installerProgressChan)
			err := installer.InstallPackages(context.Background(), m.dependencies, wm, m.sudoPassword, m.reinstallItems, installerProgressChan)
			if err != nil {
				installerProgressChan <- distros.InstallProgressMsg{
					Progress:   0.0,
					Step:       fmt.Sprintf("Installation error: %s", err.Error()),
					IsComplete: true,
					Error:      err,
				}
			}
		}()

		// Convert installer messages to TUI messages
		go func() {
			for msg := range installerProgressChan {
				tuiMsg := packageInstallProgressMsg{
					progress:    msg.Progress,
					step:        msg.Step,
					isComplete:  msg.IsComplete,
					needsSudo:   msg.NeedsSudo,
					commandInfo: msg.CommandInfo,
					logOutput:   msg.LogOutput,
					error:       msg.Error,
				}
				if msg.IsComplete {
					m.logChan <- fmt.Sprintf("[DEBUG] Sending completion signal: step=%s, progress=%.2f", msg.Step, msg.Progress)
				}
				m.packageProgressChan <- tuiMsg
			}
			m.logChan <- "[DEBUG] Installer channel closed"
		}()

		return packageInstallProgressMsg{
			progress:   0.05,
			step:       "Starting installation...",
			isComplete: false,
		}
	}
}
