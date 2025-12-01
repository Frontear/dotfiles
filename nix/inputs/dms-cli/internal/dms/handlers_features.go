//go:build !distro_binary

package dms

import (
	"context"
	"fmt"
	"os/exec"
	"strings"
	"time"

	"github.com/AvengeMedia/danklinux/internal/deps"
	"github.com/AvengeMedia/danklinux/internal/distros"
	"github.com/AvengeMedia/danklinux/internal/greeter"
	tea "github.com/charmbracelet/bubbletea"
)

func (m Model) updateUpdateView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	filteredDeps := m.getFilteredDeps()
	maxIndex := len(filteredDeps) - 1

	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StateMainMenu
	case "up", "k":
		if m.selectedUpdateDep > 0 {
			m.selectedUpdateDep--
		}
	case "down", "j":
		if m.selectedUpdateDep < maxIndex {
			m.selectedUpdateDep++
		}
	case " ":
		if dep := m.getDepAtVisualIndex(m.selectedUpdateDep); dep != nil {
			m.updateToggles[dep.Name] = !m.updateToggles[dep.Name]
		}
	case "enter":
		hasSelected := false
		for _, toggle := range m.updateToggles {
			if toggle {
				hasSelected = true
				break
			}
		}

		if !hasSelected {
			m.state = StateMainMenu
			return m, nil
		}

		m.state = StateUpdatePassword
		m.passwordInput = ""
		m.passwordError = ""
		return m, nil
	}
	return m, nil
}

func (m Model) updatePasswordView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c":
		return m, tea.Quit
	case "esc":
		m.state = StateUpdate
		m.passwordInput = ""
		m.passwordError = ""
		return m, nil
	case "enter":
		if m.passwordInput == "" {
			return m, nil
		}
		return m, m.validatePassword(m.passwordInput)
	case "backspace":
		if len(m.passwordInput) > 0 {
			m.passwordInput = m.passwordInput[:len(m.passwordInput)-1]
		}
	default:
		if len(msg.String()) == 1 && msg.String()[0] >= 32 && msg.String()[0] <= 126 {
			m.passwordInput += msg.String()
		}
	}
	return m, nil
}

func (m Model) updateProgressView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		if m.updateProgress.complete {
			m.state = StateMainMenu
			m.updateProgress = updateProgressMsg{}
			m.updateLogs = []string{}
		}
	}
	return m, nil
}

func (m Model) validatePassword(password string) tea.Cmd {
	return func() tea.Msg {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		cmd := exec.CommandContext(ctx, "sudo", "-S", "-v")
		stdin, err := cmd.StdinPipe()
		if err != nil {
			return passwordValidMsg{password: "", valid: false}
		}

		go func() {
			defer stdin.Close()
			fmt.Fprintf(stdin, "%s\n", password)
		}()

		output, err := cmd.CombinedOutput()
		outputStr := string(output)

		if err != nil {
			if strings.Contains(outputStr, "Sorry, try again") ||
				strings.Contains(outputStr, "incorrect password") ||
				strings.Contains(outputStr, "authentication failure") {
				return passwordValidMsg{password: "", valid: false}
			}
			return passwordValidMsg{password: "", valid: false}
		}

		return passwordValidMsg{password: password, valid: true}
	}
}

func (m Model) performUpdate() tea.Cmd {
	var depsToUpdate []deps.Dependency

	for _, depInfo := range m.updateDeps {
		if m.updateToggles[depInfo.Name] {
			depsToUpdate = append(depsToUpdate, deps.Dependency{
				Name:        depInfo.Name,
				Status:      depInfo.Status,
				Description: depInfo.Description,
				Required:    depInfo.Required,
			})
		}
	}

	if len(depsToUpdate) == 0 {
		return func() tea.Msg {
			return updateCompleteMsg{err: nil}
		}
	}

	wm := deps.WindowManagerHyprland
	if m.niriInstalled {
		wm = deps.WindowManagerNiri
	}

	sudoPassword := m.sudoPassword
	reinstallFlags := make(map[string]bool)
	for name, toggled := range m.updateToggles {
		if toggled {
			reinstallFlags[name] = true
		}
	}

	distribution := m.detector.GetDistribution()
	progressChan := m.updateProgressChan

	return func() tea.Msg {
		installerChan := make(chan distros.InstallProgressMsg, 100)

		go func() {
			ctx := context.Background()
			err := distribution.InstallPackages(ctx, depsToUpdate, wm, sudoPassword, reinstallFlags, installerChan)
			close(installerChan)

			if err != nil {
				progressChan <- updateProgressMsg{complete: true, err: err}
			} else {
				progressChan <- updateProgressMsg{complete: true}
			}
		}()

		go func() {
			for msg := range installerChan {
				progressChan <- updateProgressMsg{
					progress:  msg.Progress,
					step:      msg.Step,
					complete:  msg.IsComplete,
					err:       msg.Error,
					logOutput: msg.LogOutput,
				}
			}
		}()

		return nil
	}
}

func (m Model) updateGreeterMenu(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	greeterMenuItems := []string{"Install Greeter"}

	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StateMainMenu
	case "up", "k":
		if m.selectedGreeterItem > 0 {
			m.selectedGreeterItem--
		}
	case "down", "j":
		if m.selectedGreeterItem < len(greeterMenuItems)-1 {
			m.selectedGreeterItem++
		}
	case "enter", " ":
		if m.selectedGreeterItem == 0 {
			compositors := greeter.DetectCompositors()
			if len(compositors) == 0 {
				return m, nil
			}

			m.greeterCompositors = compositors

			if len(compositors) > 1 {
				m.state = StateGreeterCompositorSelect
				m.greeterSelectedComp = 0
				return m, nil
			} else {
				m.greeterChosenCompositor = compositors[0]
				m.state = StateGreeterPassword
				m.greeterPasswordInput = ""
				m.greeterPasswordError = ""
				return m, nil
			}
		}
	}
	return m, nil
}

func (m Model) updateGreeterCompositorSelect(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		m.state = StateGreeterMenu
		return m, nil
	case "up", "k":
		if m.greeterSelectedComp > 0 {
			m.greeterSelectedComp--
		}
	case "down", "j":
		if m.greeterSelectedComp < len(m.greeterCompositors)-1 {
			m.greeterSelectedComp++
		}
	case "enter", " ":
		m.greeterChosenCompositor = m.greeterCompositors[m.greeterSelectedComp]
		m.state = StateGreeterPassword
		m.greeterPasswordInput = ""
		m.greeterPasswordError = ""
		return m, nil
	}
	return m, nil
}

func (m Model) updateGreeterPasswordView(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c":
		return m, tea.Quit
	case "esc":
		m.state = StateGreeterMenu
		m.greeterPasswordInput = ""
		m.greeterPasswordError = ""
		return m, nil
	case "enter":
		if m.greeterPasswordInput == "" {
			return m, nil
		}
		return m, m.validateGreeterPassword(m.greeterPasswordInput)
	case "backspace":
		if len(m.greeterPasswordInput) > 0 {
			m.greeterPasswordInput = m.greeterPasswordInput[:len(m.greeterPasswordInput)-1]
		}
	default:
		if len(msg.String()) == 1 && msg.String()[0] >= 32 && msg.String()[0] <= 126 {
			m.greeterPasswordInput += msg.String()
		}
	}
	return m, nil
}

func (m Model) updateGreeterInstalling(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "q":
		return m, tea.Quit
	case "esc":
		if m.greeterProgress.complete {
			m.state = StateMainMenu
			m.greeterProgress = greeterProgressMsg{}
			m.greeterLogs = []string{}
		}
	}
	return m, nil
}

func (m Model) performGreeterInstall() tea.Cmd {
	progressChan := m.greeterInstallChan
	sudoPassword := m.greeterSudoPassword
	compositor := m.greeterChosenCompositor

	return func() tea.Msg {
		go func() {
			logFunc := func(msg string) {
				progressChan <- greeterProgressMsg{step: msg, logOutput: msg}
			}

			progressChan <- greeterProgressMsg{step: "Checking greetd installation..."}
			if err := performGreeterInstallSteps(progressChan, logFunc, sudoPassword, compositor); err != nil {
				progressChan <- greeterProgressMsg{step: "Installation failed", complete: true, err: err}
				return
			}

			progressChan <- greeterProgressMsg{step: "Installation complete", complete: true}
		}()
		return nil
	}
}

func (m Model) validateGreeterPassword(password string) tea.Cmd {
	return func() tea.Msg {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		cmd := exec.CommandContext(ctx, "sudo", "-S", "-v")
		stdin, err := cmd.StdinPipe()
		if err != nil {
			return greeterPasswordValidMsg{password: "", valid: false}
		}

		go func() {
			defer stdin.Close()
			fmt.Fprintf(stdin, "%s\n", password)
		}()

		output, err := cmd.CombinedOutput()
		outputStr := string(output)

		if err != nil {
			if strings.Contains(outputStr, "Sorry, try again") ||
				strings.Contains(outputStr, "incorrect password") ||
				strings.Contains(outputStr, "authentication failure") {
				return greeterPasswordValidMsg{password: "", valid: false}
			}
			return greeterPasswordValidMsg{password: "", valid: false}
		}

		return greeterPasswordValidMsg{password: password, valid: true}
	}
}

func performGreeterInstallSteps(progressChan chan greeterProgressMsg, logFunc func(string), sudoPassword string, compositor string) error {
	if err := greeter.EnsureGreetdInstalled(logFunc, sudoPassword); err != nil {
		return err
	}

	progressChan <- greeterProgressMsg{step: "Detecting DMS installation..."}
	dmsPath, err := greeter.DetectDMSPath()
	if err != nil {
		return err
	}
	logFunc(fmt.Sprintf("✓ Found DMS at: %s", dmsPath))

	logFunc(fmt.Sprintf("✓ Selected compositor: %s", compositor))

	progressChan <- greeterProgressMsg{step: "Copying greeter files..."}
	if err := greeter.CopyGreeterFiles(dmsPath, compositor, logFunc, sudoPassword); err != nil {
		return err
	}

	progressChan <- greeterProgressMsg{step: "Configuring greetd..."}
	if err := greeter.ConfigureGreetd(dmsPath, compositor, logFunc, sudoPassword); err != nil {
		return err
	}

	progressChan <- greeterProgressMsg{step: "Synchronizing DMS configurations..."}
	if err := greeter.SyncDMSConfigs(dmsPath, logFunc, sudoPassword); err != nil {
		return err
	}

	return nil
}
