package distros

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/AvengeMedia/danklinux/internal/deps"
)

func init() {
	Register("opensuse-tumbleweed", "#73BA25", FamilySUSE, func(config DistroConfig, logChan chan<- string) Distribution {
		return NewOpenSUSEDistribution(config, logChan)
	})
}

type OpenSUSEDistribution struct {
	*BaseDistribution
	*ManualPackageInstaller
	config DistroConfig
}

func NewOpenSUSEDistribution(config DistroConfig, logChan chan<- string) *OpenSUSEDistribution {
	base := NewBaseDistribution(logChan)
	return &OpenSUSEDistribution{
		BaseDistribution:       base,
		ManualPackageInstaller: &ManualPackageInstaller{BaseDistribution: base},
		config:                 config,
	}
}

func (o *OpenSUSEDistribution) GetID() string {
	return o.config.ID
}

func (o *OpenSUSEDistribution) GetColorHex() string {
	return o.config.ColorHex
}

func (o *OpenSUSEDistribution) GetFamily() DistroFamily {
	return o.config.Family
}

func (o *OpenSUSEDistribution) GetPackageManager() PackageManagerType {
	return PackageManagerZypper
}

func (o *OpenSUSEDistribution) DetectDependencies(ctx context.Context, wm deps.WindowManager) ([]deps.Dependency, error) {
	return o.DetectDependenciesWithTerminal(ctx, wm, deps.TerminalGhostty)
}

func (o *OpenSUSEDistribution) DetectDependenciesWithTerminal(ctx context.Context, wm deps.WindowManager, terminal deps.Terminal) ([]deps.Dependency, error) {
	var dependencies []deps.Dependency

	// DMS at the top (shell is prominent)
	dependencies = append(dependencies, o.detectDMS())

	// Terminal with choice support
	dependencies = append(dependencies, o.detectSpecificTerminal(terminal))

	// Common detections using base methods
	dependencies = append(dependencies, o.detectGit())
	dependencies = append(dependencies, o.detectWindowManager(wm))
	dependencies = append(dependencies, o.detectQuickshell())
	dependencies = append(dependencies, o.detectXDGPortal())
	dependencies = append(dependencies, o.detectPolkitAgent())
	dependencies = append(dependencies, o.detectAccountsService())

	// Hyprland-specific tools
	if wm == deps.WindowManagerHyprland {
		dependencies = append(dependencies, o.detectHyprlandTools()...)
	}

	// Niri-specific tools
	if wm == deps.WindowManagerNiri {
		dependencies = append(dependencies, o.detectXwaylandSatellite())
	}

	// Base detections (common across distros)
	dependencies = append(dependencies, o.detectMatugen())
	dependencies = append(dependencies, o.detectDgop())
	dependencies = append(dependencies, o.detectHyprpicker())
	dependencies = append(dependencies, o.detectClipboardTools()...)

	return dependencies, nil
}

func (o *OpenSUSEDistribution) detectXDGPortal() deps.Dependency {
	status := deps.StatusMissing
	if o.packageInstalled("xdg-desktop-portal-gtk") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "xdg-desktop-portal-gtk",
		Status:      status,
		Description: "Desktop integration portal for GTK",
		Required:    true,
	}
}

func (o *OpenSUSEDistribution) detectPolkitAgent() deps.Dependency {
	status := deps.StatusMissing
	if o.packageInstalled("mate-polkit") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "mate-polkit",
		Status:      status,
		Description: "PolicyKit authentication agent",
		Required:    true,
	}
}

func (o *OpenSUSEDistribution) packageInstalled(pkg string) bool {
	cmd := exec.Command("rpm", "-q", pkg)
	err := cmd.Run()
	return err == nil
}

func (o *OpenSUSEDistribution) GetPackageMapping(wm deps.WindowManager) map[string]PackageMapping {
	return o.GetPackageMappingWithVariants(wm, make(map[string]deps.PackageVariant))
}

func (o *OpenSUSEDistribution) GetPackageMappingWithVariants(wm deps.WindowManager, variants map[string]deps.PackageVariant) map[string]PackageMapping {
	packages := map[string]PackageMapping{
		// Standard zypper packages
		"git":                    {Name: "git", Repository: RepoTypeSystem},
		"ghostty":                {Name: "ghostty", Repository: RepoTypeSystem},
		"kitty":                  {Name: "kitty", Repository: RepoTypeSystem},
		"alacritty":              {Name: "alacritty", Repository: RepoTypeSystem},
		"wl-clipboard":           {Name: "wl-clipboard", Repository: RepoTypeSystem},
		"xdg-desktop-portal-gtk": {Name: "xdg-desktop-portal-gtk", Repository: RepoTypeSystem},
		"mate-polkit":            {Name: "mate-polkit", Repository: RepoTypeSystem},
		"accountsservice":        {Name: "accountsservice", Repository: RepoTypeSystem},
		"cliphist":               {Name: "cliphist", Repository: RepoTypeSystem},
		"hyprpicker":             {Name: "hyprpicker", Repository: RepoTypeSystem},

		// Manual builds
		"dms (DankMaterialShell)": {Name: "dms", Repository: RepoTypeManual, BuildFunc: "installDankMaterialShell"},
		"dgop":                    {Name: "dgop", Repository: RepoTypeManual, BuildFunc: "installDgop"},
		"quickshell":              {Name: "quickshell", Repository: RepoTypeManual, BuildFunc: "installQuickshell"},
		"matugen":                 {Name: "matugen", Repository: RepoTypeManual, BuildFunc: "installMatugen"},
	}

	switch wm {
	case deps.WindowManagerHyprland:
		packages["hyprland"] = PackageMapping{Name: "hyprland", Repository: RepoTypeSystem}
		packages["grim"] = PackageMapping{Name: "grim", Repository: RepoTypeSystem}
		packages["slurp"] = PackageMapping{Name: "slurp", Repository: RepoTypeSystem}
		packages["hyprctl"] = PackageMapping{Name: "hyprland", Repository: RepoTypeSystem}
		packages["grimblast"] = PackageMapping{Name: "grimblast", Repository: RepoTypeManual, BuildFunc: "installGrimblast"}
		packages["jq"] = PackageMapping{Name: "jq", Repository: RepoTypeSystem}
	case deps.WindowManagerNiri:
		packages["niri"] = PackageMapping{Name: "niri", Repository: RepoTypeSystem}
		packages["xwayland-satellite"] = PackageMapping{Name: "xwayland-satellite", Repository: RepoTypeSystem}
	}

	return packages
}

func (o *OpenSUSEDistribution) detectXwaylandSatellite() deps.Dependency {
	status := deps.StatusMissing
	if o.commandExists("xwayland-satellite") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "xwayland-satellite",
		Status:      status,
		Description: "Xwayland support",
		Required:    true,
	}
}

func (o *OpenSUSEDistribution) detectAccountsService() deps.Dependency {
	status := deps.StatusMissing
	if o.packageInstalled("accountsservice") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "accountsservice",
		Status:      status,
		Description: "D-Bus interface for user account query and manipulation",
		Required:    true,
	}
}

func (o *OpenSUSEDistribution) getPrerequisites() []string {
	return []string{
		"make",
		"unzip",
		"gcc",
		"gcc-c++",
		"cmake",
		"ninja",
		"pkgconf-pkg-config",
		"git",
		"qt6-base-devel",
		"qt6-declarative-devel",
		"qt6-declarative-private-devel",
		"qt6-shadertools",
		"qt6-shadertools-devel",
		"qt6-wayland-devel",
		"qt6-waylandclient-private-devel",
		"spirv-tools-devel",
		"cli11-devel",
		"wayland-protocols-devel",
		"libgbm-devel",
		"libdrm-devel",
		"pipewire-devel",
		"jemalloc-devel",
		"wayland-utils",
		"Mesa-libGLESv3-devel",
		"pam-devel",
		"glib2-devel",
		"polkit-devel",
	}
}

func (o *OpenSUSEDistribution) InstallPrerequisites(ctx context.Context, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	prerequisites := o.getPrerequisites()
	var missingPkgs []string

	progressChan <- InstallProgressMsg{
		Phase:      PhasePrerequisites,
		Progress:   0.06,
		Step:       "Checking prerequisites...",
		IsComplete: false,
		LogOutput:  "Checking prerequisite packages",
	}

	for _, pkg := range prerequisites {
		checkCmd := exec.CommandContext(ctx, "rpm", "-q", pkg)
		if err := checkCmd.Run(); err != nil {
			missingPkgs = append(missingPkgs, pkg)
		}
	}

	_, err := exec.LookPath("go")
	if err != nil {
		o.log("go not found in PATH, will install go")
		missingPkgs = append(missingPkgs, "go")
	} else {
		o.log("go already available in PATH")
	}

	if len(missingPkgs) == 0 {
		o.log("All prerequisites already installed")
		return nil
	}

	o.log(fmt.Sprintf("Installing prerequisites: %s", strings.Join(missingPkgs, ", ")))
	progressChan <- InstallProgressMsg{
		Phase:       PhasePrerequisites,
		Progress:    0.08,
		Step:        fmt.Sprintf("Installing %d prerequisites...", len(missingPkgs)),
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: fmt.Sprintf("sudo zypper install -y %s", strings.Join(missingPkgs, " ")),
		LogOutput:   fmt.Sprintf("Installing prerequisites: %s", strings.Join(missingPkgs, ", ")),
	}

	args := []string{"zypper", "install", "-y"}
	args = append(args, missingPkgs...)
	cmdStr := fmt.Sprintf("echo '%s' | sudo -S %s", sudoPassword, strings.Join(args, " "))
	cmd := exec.CommandContext(ctx, "bash", "-c", cmdStr)
	output, err := cmd.CombinedOutput()
	if err != nil {
		o.logError("failed to install prerequisites", err)
		o.log(fmt.Sprintf("Prerequisites command output: %s", string(output)))
		return fmt.Errorf("failed to install prerequisites: %w", err)
	}
	o.log(fmt.Sprintf("Prerequisites install output: %s", string(output)))

	return nil
}

func (o *OpenSUSEDistribution) InstallPackages(ctx context.Context, dependencies []deps.Dependency, wm deps.WindowManager, sudoPassword string, reinstallFlags map[string]bool, progressChan chan<- InstallProgressMsg) error {
	// Phase 1: Check Prerequisites
	progressChan <- InstallProgressMsg{
		Phase:      PhasePrerequisites,
		Progress:   0.05,
		Step:       "Checking system prerequisites...",
		IsComplete: false,
		LogOutput:  "Starting prerequisite check...",
	}

	if err := o.InstallPrerequisites(ctx, sudoPassword, progressChan); err != nil {
		return fmt.Errorf("failed to install prerequisites: %w", err)
	}

	systemPkgs, manualPkgs := o.categorizePackages(dependencies, wm, reinstallFlags)

	// Phase 2: System Packages (Zypper)
	if len(systemPkgs) > 0 {
		progressChan <- InstallProgressMsg{
			Phase:      PhaseSystemPackages,
			Progress:   0.35,
			Step:       fmt.Sprintf("Installing %d system packages...", len(systemPkgs)),
			IsComplete: false,
			NeedsSudo:  true,
			LogOutput:  fmt.Sprintf("Installing system packages: %s", strings.Join(systemPkgs, ", ")),
		}
		if err := o.installZypperPackages(ctx, systemPkgs, sudoPassword, progressChan); err != nil {
			return fmt.Errorf("failed to install zypper packages: %w", err)
		}
	}

	// Phase 3: Manual Builds
	if len(manualPkgs) > 0 {
		progressChan <- InstallProgressMsg{
			Phase:      PhaseSystemPackages,
			Progress:   0.85,
			Step:       fmt.Sprintf("Building %d packages from source...", len(manualPkgs)),
			IsComplete: false,
			LogOutput:  fmt.Sprintf("Building from source: %s", strings.Join(manualPkgs, ", ")),
		}
		if err := o.InstallManualPackages(ctx, manualPkgs, sudoPassword, progressChan); err != nil {
			return fmt.Errorf("failed to install manual packages: %w", err)
		}
	}

	// Phase 4: Configuration
	progressChan <- InstallProgressMsg{
		Phase:      PhaseConfiguration,
		Progress:   0.90,
		Step:       "Configuring system...",
		IsComplete: false,
		LogOutput:  "Starting post-installation configuration...",
	}

	// Phase 5: Complete
	progressChan <- InstallProgressMsg{
		Phase:      PhaseComplete,
		Progress:   1.0,
		Step:       "Installation complete!",
		IsComplete: true,
		LogOutput:  "All packages installed and configured successfully",
	}

	return nil
}

func (o *OpenSUSEDistribution) categorizePackages(dependencies []deps.Dependency, wm deps.WindowManager, reinstallFlags map[string]bool) ([]string, []string) {
	systemPkgs := []string{}
	manualPkgs := []string{}

	variantMap := make(map[string]deps.PackageVariant)
	for _, dep := range dependencies {
		variantMap[dep.Name] = dep.Variant
	}

	packageMap := o.GetPackageMappingWithVariants(wm, variantMap)

	for _, dep := range dependencies {
		// Skip installed packages unless marked for reinstall
		if dep.Status == deps.StatusInstalled && !reinstallFlags[dep.Name] {
			continue
		}

		pkgInfo, exists := packageMap[dep.Name]
		if !exists {
			o.log(fmt.Sprintf("Warning: No package mapping for %s", dep.Name))
			continue
		}

		switch pkgInfo.Repository {
		case RepoTypeSystem:
			systemPkgs = append(systemPkgs, pkgInfo.Name)
		case RepoTypeManual:
			manualPkgs = append(manualPkgs, dep.Name)
		}
	}

	return systemPkgs, manualPkgs
}

func (o *OpenSUSEDistribution) installZypperPackages(ctx context.Context, packages []string, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	if len(packages) == 0 {
		return nil
	}

	o.log(fmt.Sprintf("Installing zypper packages: %s", strings.Join(packages, ", ")))

	args := []string{"zypper", "install", "-y"}
	args = append(args, packages...)

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.40,
		Step:        "Installing system packages...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: fmt.Sprintf("sudo %s", strings.Join(args, " ")),
	}

	cmdStr := fmt.Sprintf("echo '%s' | sudo -S %s", sudoPassword, strings.Join(args, " "))
	cmd := exec.CommandContext(ctx, "bash", "-c", cmdStr)
	return o.runWithProgress(cmd, progressChan, PhaseSystemPackages, 0.40, 0.60)
}

// installQuickshell overrides the base implementation to set openSUSE-specific CFLAGS
func (o *OpenSUSEDistribution) installQuickshell(ctx context.Context, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	o.log("Installing quickshell from source (with openSUSE-specific build flags)...")

	homeDir := os.Getenv("HOME")
	if homeDir == "" {
		return fmt.Errorf("HOME environment variable not set")
	}

	cacheDir := filepath.Join(homeDir, ".cache", "dankinstall")
	if err := os.MkdirAll(cacheDir, 0755); err != nil {
		return fmt.Errorf("failed to create cache directory: %w", err)
	}

	tmpDir := filepath.Join(cacheDir, "quickshell-build")
	if err := os.MkdirAll(tmpDir, 0755); err != nil {
		return fmt.Errorf("failed to create temp directory: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.1,
		Step:        "Cloning quickshell repository...",
		IsComplete:  false,
		CommandInfo: "git clone https://github.com/quickshell-mirror/quickshell.git",
	}

	var cloneCmd *exec.Cmd
	if forceQuickshellGit {
		cloneCmd = exec.CommandContext(ctx, "git", "clone", "https://github.com/quickshell-mirror/quickshell.git", tmpDir)
	} else {
		// Get latest tag from repository
		latestTag := o.getLatestQuickshellTag(ctx)
		if latestTag != "" {
			o.log(fmt.Sprintf("Using latest quickshell tag: %s", latestTag))
			cloneCmd = exec.CommandContext(ctx, "git", "clone", "--branch", latestTag, "https://github.com/quickshell-mirror/quickshell.git", tmpDir)
		} else {
			o.log("Warning: failed to fetch latest tag, using default branch")
			cloneCmd = exec.CommandContext(ctx, "git", "clone", "https://github.com/quickshell-mirror/quickshell.git", tmpDir)
		}
	}
	if err := cloneCmd.Run(); err != nil {
		return fmt.Errorf("failed to clone quickshell: %w", err)
	}

	buildDir := tmpDir + "/build"
	if err := os.MkdirAll(buildDir, 0755); err != nil {
		return fmt.Errorf("failed to create build directory: %w", err)
	}

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.3,
		Step:        "Configuring quickshell build (with openSUSE flags)...",
		IsComplete:  false,
		CommandInfo: "cmake -B build -S . -G Ninja",
	}

	// Get optflags from rpm
	optflagsCmd := exec.CommandContext(ctx, "rpm", "--eval", "%{optflags}")
	optflagsOutput, err := optflagsCmd.Output()
	optflags := strings.TrimSpace(string(optflagsOutput))
	if err != nil || optflags == "" {
		o.log("Warning: Could not get optflags from rpm, using default -O2 -g")
		optflags = "-O2 -g"
	}

	// Set openSUSE-specific CFLAGS
	customCFLAGS := fmt.Sprintf("%s -I/usr/include/wayland", optflags)

	configureCmd := exec.CommandContext(ctx, "cmake", "-GNinja", "-B", "build",
		"-DCMAKE_BUILD_TYPE=RelWithDebInfo",
		"-DCRASH_REPORTER=off",
		"-DCMAKE_CXX_STANDARD=20")
	configureCmd.Dir = tmpDir
	configureCmd.Env = append(os.Environ(),
		"TMPDIR="+cacheDir,
		"CFLAGS="+customCFLAGS,
		"CXXFLAGS="+customCFLAGS)

	o.log(fmt.Sprintf("Using CFLAGS: %s", customCFLAGS))

	output, err := configureCmd.CombinedOutput()
	if err != nil {
		o.log(fmt.Sprintf("cmake configure failed. Output:\n%s", string(output)))
		return fmt.Errorf("failed to configure quickshell: %w\nCMake output:\n%s", err, string(output))
	}

	o.log(fmt.Sprintf("cmake configure successful. Output:\n%s", string(output)))

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.4,
		Step:        "Building quickshell (this may take a while)...",
		IsComplete:  false,
		CommandInfo: "cmake --build build",
	}

	buildCmd := exec.CommandContext(ctx, "cmake", "--build", "build")
	buildCmd.Dir = tmpDir
	buildCmd.Env = append(os.Environ(),
		"TMPDIR="+cacheDir,
		"CFLAGS="+customCFLAGS,
		"CXXFLAGS="+customCFLAGS)
	if err := o.runWithProgressStep(buildCmd, progressChan, PhaseSystemPackages, 0.4, 0.8, "Building quickshell..."); err != nil {
		return fmt.Errorf("failed to build quickshell: %w", err)
	}

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.8,
		Step:        "Installing quickshell...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: "sudo cmake --install build",
	}

	installCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("cd %s && echo '%s' | sudo -S cmake --install build", tmpDir, sudoPassword))
	if err := installCmd.Run(); err != nil {
		return fmt.Errorf("failed to install quickshell: %w", err)
	}

	o.log("quickshell installed successfully from source")
	return nil
}

func (o *OpenSUSEDistribution) installRust(ctx context.Context, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	if o.commandExists("cargo") {
		return nil
	}

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.82,
		Step:        "Installing rustup...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: "sudo zypper install rustup",
	}

	rustupInstallCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S zypper install -y rustup", sudoPassword))
	if err := o.runWithProgress(rustupInstallCmd, progressChan, PhaseSystemPackages, 0.82, 0.83); err != nil {
		return fmt.Errorf("failed to install rustup: %w", err)
	}

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.83,
		Step:        "Installing stable Rust toolchain...",
		IsComplete:  false,
		CommandInfo: "rustup install stable",
	}

	rustInstallCmd := exec.CommandContext(ctx, "bash", "-c", "rustup install stable && rustup default stable")
	if err := o.runWithProgress(rustInstallCmd, progressChan, PhaseSystemPackages, 0.83, 0.84); err != nil {
		return fmt.Errorf("failed to install Rust toolchain: %w", err)
	}

	if !o.commandExists("cargo") {
		o.log("Warning: cargo not found in PATH after Rust installation, trying to source environment")
	}

	return nil
}

// InstallManualPackages overrides the base implementation to use openSUSE-specific builds
func (o *OpenSUSEDistribution) InstallManualPackages(ctx context.Context, packages []string, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	if len(packages) == 0 {
		return nil
	}

	o.log(fmt.Sprintf("Installing manual packages: %s", strings.Join(packages, ", ")))

	// Install Rust if needed for matugen
	for _, pkg := range packages {
		if pkg == "matugen" {
			if err := o.installRust(ctx, sudoPassword, progressChan); err != nil {
				return fmt.Errorf("failed to install Rust: %w", err)
			}
			break
		}
	}

	for _, pkg := range packages {
		if pkg == "quickshell" {
			if err := o.installQuickshell(ctx, sudoPassword, progressChan); err != nil {
				return fmt.Errorf("failed to install quickshell: %w", err)
			}
		} else {
			// Use the base ManualPackageInstaller for other packages
			if err := o.ManualPackageInstaller.InstallManualPackages(ctx, []string{pkg}, sudoPassword, progressChan); err != nil {
				return fmt.Errorf("failed to install %s: %w", pkg, err)
			}
		}
	}

	return nil
}
