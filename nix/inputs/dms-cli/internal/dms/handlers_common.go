package dms

import (
	"os/exec"
	"time"

	"github.com/AvengeMedia/danklinux/internal/log"
	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) updateShellView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StateMainMenu
	default:
		return m, tea.Quit
	}
	return m, nil
}

func (m Model) updateAboutView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q", "esc":
		if msg.String() == "esc" {
			m.state = StateMainMenu
		} else {
			return m, tea.Quit
		}
	}
	return m, nil
}

func terminateShell() {
	patterns := []string{"dms run", "qs -c dms"}
	for _, pattern := range patterns {
		cmd := exec.Command("pkill", "-f", pattern)
		cmd.Run()
	}
}

func startShellDaemon() {
	cmd := exec.Command("dms", "run", "-d")
	if err := cmd.Start(); err != nil {
		log.Errorf("Error starting daemon: %v", err)
	}
}

func restartShell() {
	terminateShell()
	time.Sleep(500 * time.Millisecond)
	startShellDaemon()
}
