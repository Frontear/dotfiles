package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"

	"github.com/AvengeMedia/danklinux/internal/greeter"
	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/spf13/cobra"
)

var greeterCmd = &cobra.Command{
	Use:   "greeter",
	Short: "Manage DMS greeter",
	Long:  "Manage DMS greeter (greetd)",
}

var greeterInstallCmd = &cobra.Command{
	Use:   "install",
	Short: "Install and configure DMS greeter",
	Long:  "Install greetd and configure it to use DMS as the greeter interface",
	Run: func(cmd *cobra.Command, args []string) {
		if err := installGreeter(); err != nil {
			log.Fatalf("Error installing greeter: %v", err)
		}
	},
}

var greeterSyncCmd = &cobra.Command{
	Use:   "sync",
	Short: "Sync DMS theme and settings with greeter",
	Long:  "Synchronize your current user's DMS theme, settings, and wallpaper configuration with the login greeter screen",
	Run: func(cmd *cobra.Command, args []string) {
		if err := syncGreeter(); err != nil {
			log.Fatalf("Error syncing greeter: %v", err)
		}
	},
}

var greeterEnableCmd = &cobra.Command{
	Use:   "enable",
	Short: "Enable DMS greeter in greetd config",
	Long:  "Configure greetd to use DMS as the greeter",
	Run: func(cmd *cobra.Command, args []string) {
		if err := enableGreeter(); err != nil {
			log.Fatalf("Error enabling greeter: %v", err)
		}
	},
}

var greeterStatusCmd = &cobra.Command{
	Use:   "status",
	Short: "Check greeter sync status",
	Long:  "Check the status of greeter installation and configuration sync",
	Run: func(cmd *cobra.Command, args []string) {
		if err := checkGreeterStatus(); err != nil {
			log.Fatalf("Error checking greeter status: %v", err)
		}
	},
}

func installGreeter() error {
	fmt.Println("=== DMS Greeter Installation ===")

	logFunc := func(msg string) {
		fmt.Println(msg)
	}

	if err := greeter.EnsureGreetdInstalled(logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\nDetecting DMS installation...")
	dmsPath, err := greeter.DetectDMSPath()
	if err != nil {
		return err
	}
	fmt.Printf("✓ Found DMS at: %s\n", dmsPath)

	fmt.Println("\nDetecting installed compositors...")
	compositors := greeter.DetectCompositors()
	if len(compositors) == 0 {
		return fmt.Errorf("no supported compositors found (niri or Hyprland required)")
	}

	var selectedCompositor string
	if len(compositors) == 1 {
		selectedCompositor = compositors[0]
		fmt.Printf("✓ Found compositor: %s\n", selectedCompositor)
	} else {
		var err error
		selectedCompositor, err = greeter.PromptCompositorChoice(compositors)
		if err != nil {
			return err
		}
		fmt.Printf("✓ Selected compositor: %s\n", selectedCompositor)
	}

	fmt.Println("\nSetting up dms-greeter group and permissions...")
	if err := greeter.SetupDMSGroup(logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\nCopying greeter files...")
	if err := greeter.CopyGreeterFiles(dmsPath, selectedCompositor, logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\nConfiguring greetd...")
	if err := greeter.ConfigureGreetd(dmsPath, selectedCompositor, logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\nSynchronizing DMS configurations...")
	if err := greeter.SyncDMSConfigs(dmsPath, logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\n=== Installation Complete ===")
	fmt.Println("\nTo test the greeter, run:")
	fmt.Println("  sudo systemctl start greetd")
	fmt.Println("\nTo enable on boot, run:")
	fmt.Println("  sudo systemctl enable --now greetd")

	return nil
}

func syncGreeter() error {
	fmt.Println("=== DMS Greeter Theme Sync ===")
	fmt.Println()

	logFunc := func(msg string) {
		fmt.Println(msg)
	}

	fmt.Println("Detecting DMS installation...")
	dmsPath, err := greeter.DetectDMSPath()
	if err != nil {
		return err
	}
	fmt.Printf("✓ Found DMS at: %s\n", dmsPath)

	cacheDir := "/var/cache/dms-greeter"
	if _, err := os.Stat(cacheDir); os.IsNotExist(err) {
		return fmt.Errorf("greeter cache directory not found at %s\nPlease install the greeter first", cacheDir)
	}

	greeterGroupExists := checkGroupExists("greeter")
	if greeterGroupExists {
		currentUser, err := user.Current()
		if err != nil {
			return fmt.Errorf("failed to get current user: %w", err)
		}

		groupsCmd := exec.Command("groups", currentUser.Username)
		groupsOutput, err := groupsCmd.Output()
		if err != nil {
			return fmt.Errorf("failed to check groups: %w", err)
		}

		inGreeterGroup := strings.Contains(string(groupsOutput), "greeter")
		if !inGreeterGroup {
			fmt.Println("\n⚠ Warning: You are not in the greeter group.")
			fmt.Print("Would you like to add your user to the greeter group? (y/N): ")

			var response string
			fmt.Scanln(&response)
			response = strings.ToLower(strings.TrimSpace(response))

			if response == "y" || response == "yes" {
				fmt.Println("\nAdding user to greeter group...")
				addUserCmd := exec.Command("sudo", "usermod", "-aG", "greeter", currentUser.Username)
				addUserCmd.Stdout = os.Stdout
				addUserCmd.Stderr = os.Stderr
				if err := addUserCmd.Run(); err != nil {
					return fmt.Errorf("failed to add user to greeter group: %w", err)
				}
				fmt.Println("✓ User added to greeter group")
				fmt.Println("⚠ You will need to log out and back in for the group change to take effect")
			}
		}
	}

	fmt.Println("\nSetting up permissions and ACLs...")
	if err := greeter.SetupDMSGroup(logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\nSynchronizing DMS configurations...")
	if err := greeter.SyncDMSConfigs(dmsPath, logFunc, ""); err != nil {
		return err
	}

	fmt.Println("\n=== Sync Complete ===")
	fmt.Println("\nYour theme, settings, and wallpaper configuration have been synced with the greeter.")
	fmt.Println("The changes will be visible on the next login screen.")

	return nil
}

func checkGroupExists(groupName string) bool {
	data, err := os.ReadFile("/etc/group")
	if err != nil {
		return false
	}

	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, groupName+":") {
			return true
		}
	}
	return false
}

func enableGreeter() error {
	fmt.Println("=== DMS Greeter Enable ===")
	fmt.Println()

	configPath := "/etc/greetd/config.toml"
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("greetd config not found at %s\nPlease install greetd first", configPath)
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("failed to read greetd config: %w", err)
	}

	configContent := string(data)
	if strings.Contains(configContent, "dms-greeter") {
		fmt.Println("✓ Greeter is already configured with dms-greeter")
		return nil
	}

	fmt.Println("Detecting installed compositors...")
	compositors := greeter.DetectCompositors()

	if commandExists("sway") {
		compositors = append(compositors, "sway")
	}

	if len(compositors) == 0 {
		return fmt.Errorf("no supported compositors found (niri, Hyprland, or sway required)")
	}

	var selectedCompositor string
	if len(compositors) == 1 {
		selectedCompositor = compositors[0]
		fmt.Printf("✓ Found compositor: %s\n", selectedCompositor)
	} else {
		var err error
		selectedCompositor, err = promptCompositorChoice(compositors)
		if err != nil {
			return err
		}
		fmt.Printf("✓ Selected compositor: %s\n", selectedCompositor)
	}

	backupPath := configPath + ".backup"
	backupCmd := exec.Command("sudo", "cp", configPath, backupPath)
	if err := backupCmd.Run(); err != nil {
		return fmt.Errorf("failed to backup config: %w", err)
	}
	fmt.Printf("✓ Backed up config to %s\n", backupPath)

	lines := strings.Split(configContent, "\n")
	var newLines []string
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if !strings.HasPrefix(trimmed, "command =") && !strings.HasPrefix(trimmed, "command=") {
			newLines = append(newLines, line)
		}
	}

	wrapperCmd := "dms-greeter"
	if !commandExists("dms-greeter") {
		wrapperCmd = "/usr/local/bin/dms-greeter"
	}

	compositorLower := strings.ToLower(selectedCompositor)
	commandLine := fmt.Sprintf(`command = "%s --command %s"`, wrapperCmd, compositorLower)

	var finalLines []string
	inDefaultSession := false
	commandAdded := false

	for _, line := range newLines {
		finalLines = append(finalLines, line)
		trimmed := strings.TrimSpace(line)

		if trimmed == "[default_session]" {
			inDefaultSession = true
		}

		if inDefaultSession && !commandAdded {
			if strings.HasPrefix(trimmed, "user =") || strings.HasPrefix(trimmed, "user=") {
				finalLines = append(finalLines, commandLine)
				commandAdded = true
			}
		}
	}

	if !commandAdded {
		finalLines = append(finalLines, commandLine)
	}

	newConfig := strings.Join(finalLines, "\n")

	tmpFile := "/tmp/greetd-config.toml"
	if err := os.WriteFile(tmpFile, []byte(newConfig), 0644); err != nil {
		return fmt.Errorf("failed to write temp config: %w", err)
	}

	moveCmd := exec.Command("sudo", "mv", tmpFile, configPath)
	if err := moveCmd.Run(); err != nil {
		return fmt.Errorf("failed to update config: %w", err)
	}

	fmt.Printf("✓ Updated greetd configuration to use %s\n", selectedCompositor)
	fmt.Println("\n=== Enable Complete ===")
	fmt.Println("\nTo start the greeter, run:")
	fmt.Println("  sudo systemctl start greetd")
	fmt.Println("\nTo enable on boot, run:")
	fmt.Println("  sudo systemctl enable --now greetd")

	return nil
}

func promptCompositorChoice(compositors []string) (string, error) {
	fmt.Println("\nMultiple compositors detected:")
	for i, comp := range compositors {
		fmt.Printf("%d) %s\n", i+1, comp)
	}

	var response string
	fmt.Print("Choose compositor for greeter: ")
	fmt.Scanln(&response)
	response = strings.TrimSpace(response)

	choice := 0
	fmt.Sscanf(response, "%d", &choice)

	if choice < 1 || choice > len(compositors) {
		return "", fmt.Errorf("invalid choice")
	}

	return compositors[choice-1], nil
}

func checkGreeterStatus() error {
	fmt.Println("=== DMS Greeter Status ===")
	fmt.Println()

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get user home directory: %w", err)
	}

	currentUser, err := user.Current()
	if err != nil {
		return fmt.Errorf("failed to get current user: %w", err)
	}

	configPath := "/etc/greetd/config.toml"
	fmt.Println("Greeter Configuration:")
	if data, err := os.ReadFile(configPath); err == nil {
		configContent := string(data)
		if strings.Contains(configContent, "dms-greeter") {
			lines := strings.Split(configContent, "\n")
			for _, line := range lines {
				trimmed := strings.TrimSpace(line)
				if strings.HasPrefix(trimmed, "command =") || strings.HasPrefix(trimmed, "command=") {
					parts := strings.SplitN(trimmed, "=", 2)
					if len(parts) == 2 {
						command := strings.Trim(strings.TrimSpace(parts[1]), `"`)
						fmt.Println("  ✓ Greeter is enabled")

						if strings.Contains(command, "--command niri") {
							fmt.Println("  Compositor: niri")
						} else if strings.Contains(command, "--command hyprland") {
							fmt.Println("  Compositor: Hyprland")
						} else if strings.Contains(command, "--command sway") {
							fmt.Println("  Compositor: sway")
						} else {
							fmt.Println("  Compositor: unknown")
						}
					}
					break
				}
			}
		} else {
			fmt.Println("  ✗ Greeter is NOT enabled")
			fmt.Println("    Run 'dms greeter enable' to enable it")
		}
	} else {
		fmt.Println("  ✗ Greeter config not found")
		fmt.Println("    Run 'dms greeter install' to install greeter")
	}

	fmt.Println("\nGroup Membership:")
	groupsCmd := exec.Command("groups", currentUser.Username)
	groupsOutput, err := groupsCmd.Output()
	if err != nil {
		return fmt.Errorf("failed to check groups: %w", err)
	}

	inGreeterGroup := strings.Contains(string(groupsOutput), "greeter")
	if inGreeterGroup {
		fmt.Println("  ✓ User is in greeter group")
	} else {
		fmt.Println("  ✗ User is NOT in greeter group")
		fmt.Println("    Run 'dms greeter install' to add user to greeter group")
	}

	cacheDir := "/var/cache/dms-greeter"
	fmt.Println("\nGreeter Cache Directory:")
	if stat, err := os.Stat(cacheDir); err == nil && stat.IsDir() {
		fmt.Printf("  ✓ %s exists\n", cacheDir)
	} else {
		fmt.Printf("  ✗ %s not found\n", cacheDir)
		fmt.Println("    Run 'dms greeter install' to create cache directory")
		return nil
	}

	fmt.Println("\nConfiguration Symlinks:")
	symlinks := []struct {
		source string
		target string
		desc   string
	}{
		{
			source: filepath.Join(homeDir, ".config", "DankMaterialShell", "settings.json"),
			target: filepath.Join(cacheDir, "settings.json"),
			desc:   "Settings",
		},
		{
			source: filepath.Join(homeDir, ".local", "state", "DankMaterialShell", "session.json"),
			target: filepath.Join(cacheDir, "session.json"),
			desc:   "Session state",
		},
		{
			source: filepath.Join(homeDir, ".cache", "quickshell", "dankshell", "dms-colors.json"),
			target: filepath.Join(cacheDir, "colors.json"),
			desc:   "Color theme",
		},
	}

	allGood := true
	for _, link := range symlinks {
		targetInfo, err := os.Lstat(link.target)
		if err != nil {
			fmt.Printf("  ✗ %s: symlink not found at %s\n", link.desc, link.target)
			allGood = false
			continue
		}

		if targetInfo.Mode()&os.ModeSymlink == 0 {
			fmt.Printf("  ✗ %s: %s is not a symlink\n", link.desc, link.target)
			allGood = false
			continue
		}

		linkDest, err := os.Readlink(link.target)
		if err != nil {
			fmt.Printf("  ✗ %s: failed to read symlink\n", link.desc)
			allGood = false
			continue
		}

		if linkDest != link.source {
			fmt.Printf("  ✗ %s: symlink points to wrong location\n", link.desc)
			fmt.Printf("    Expected: %s\n", link.source)
			fmt.Printf("    Got: %s\n", linkDest)
			allGood = false
			continue
		}

		if _, err := os.Stat(link.source); os.IsNotExist(err) {
			fmt.Printf("  ⚠ %s: symlink OK, but source file doesn't exist yet\n", link.desc)
			fmt.Printf("    Will be created when you run DMS\n")
			continue
		}

		fmt.Printf("  ✓ %s: synced correctly\n", link.desc)
	}

	fmt.Println()
	if allGood && inGreeterGroup {
		fmt.Println("✓ All checks passed! Greeter is properly configured.")
	} else if !allGood {
		fmt.Println("⚠ Some issues detected. Run 'dms greeter sync' to fix symlinks.")
	}

	return nil
}
