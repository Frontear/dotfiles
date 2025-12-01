package tui

import (
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) viewMissingWMInstructions() string {
	var b strings.Builder

	b.WriteString(m.renderBanner())
	b.WriteString("\n\n")

	// Determine which WM is missing
	wmName := "Niri"
	installCmd := `environment.systemPackages = with pkgs; [
  niri
];`
	alternateCmd := `# Or enable the module if available:
# programs.niri.enable = true;`

	if m.selectedWM == 1 {
		wmName = "Hyprland"
		installCmd = `programs.hyprland.enable = true;`
		alternateCmd = `# Or add to systemPackages:
# environment.systemPackages = with pkgs; [
#   hyprland
# ];`
	}

	// Title
	title := m.styles.Title.Render("⚠️  " + wmName + " Not Installed")
	b.WriteString(title)
	b.WriteString("\n\n")

	// Explanation
	explanation := m.styles.Normal.Render(wmName + " needs to be installed system-wide on NixOS.")
	b.WriteString(explanation)
	b.WriteString("\n\n")

	// Instructions
	instructions := m.styles.Subtle.Render("To install " + wmName + ", add this to your /etc/nixos/configuration.nix:")
	b.WriteString(instructions)
	b.WriteString("\n\n")

	// Command box
	cmdBox := m.styles.CodeBlock.Render(installCmd)
	b.WriteString(cmdBox)
	b.WriteString("\n\n")

	// Alternate command
	altBox := m.styles.Subtle.Render(alternateCmd)
	b.WriteString(altBox)
	b.WriteString("\n\n")

	// Rebuild instruction
	rebuildInstruction := m.styles.Normal.Render("Then rebuild your system:")
	b.WriteString(rebuildInstruction)
	b.WriteString("\n")

	rebuildCmd := m.styles.CodeBlock.Render("sudo nixos-rebuild switch")
	b.WriteString(rebuildCmd)
	b.WriteString("\n\n")

	// Navigation help
	help := m.styles.Subtle.Render("Press Esc to go back and select a different window manager, or Ctrl+C to exit")
	b.WriteString(help)

	return b.String()
}

func (m Model) updateMissingWMInstructionsState(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "esc":
			// Go back to window manager selection
			m.state = StateSelectWindowManager
			return m, m.listenForLogs()
		case "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, m.listenForLogs()
}
