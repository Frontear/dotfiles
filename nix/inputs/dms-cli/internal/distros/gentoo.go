package distros

import (
	"context"
	"fmt"
	"os/exec"
	"strings"

	"github.com/AvengeMedia/danklinux/internal/deps"
)

func init() {
	Register("gentoo", "#54487A", FamilyGentoo, func(config DistroConfig, logChan chan<- string) Distribution {
		return NewGentooDistribution(config, logChan)
	})
}

type GentooDistribution struct {
	*BaseDistribution
	*ManualPackageInstaller
	config DistroConfig
}

func NewGentooDistribution(config DistroConfig, logChan chan<- string) *GentooDistribution {
	base := NewBaseDistribution(logChan)
	return &GentooDistribution{
		BaseDistribution:       base,
		ManualPackageInstaller: &ManualPackageInstaller{BaseDistribution: base},
		config:                 config,
	}
}

func (g *GentooDistribution) GetID() string {
	return g.config.ID
}

func (g *GentooDistribution) GetColorHex() string {
	return g.config.ColorHex
}

func (g *GentooDistribution) GetFamily() DistroFamily {
	return g.config.Family
}

func (g *GentooDistribution) GetPackageManager() PackageManagerType {
	return PackageManagerPortage
}

func (g *GentooDistribution) DetectDependencies(ctx context.Context, wm deps.WindowManager) ([]deps.Dependency, error) {
	return g.DetectDependenciesWithTerminal(ctx, wm, deps.TerminalGhostty)
}

func (g *GentooDistribution) DetectDependenciesWithTerminal(ctx context.Context, wm deps.WindowManager, terminal deps.Terminal) ([]deps.Dependency, error) {
	var dependencies []deps.Dependency

	dependencies = append(dependencies, g.detectDMS())

	dependencies = append(dependencies, g.detectSpecificTerminal(terminal))

	dependencies = append(dependencies, g.detectGit())
	dependencies = append(dependencies, g.detectWindowManager(wm))
	dependencies = append(dependencies, g.detectQuickshell())
	dependencies = append(dependencies, g.detectXDGPortal())
	dependencies = append(dependencies, g.detectPolkitAgent())
	dependencies = append(dependencies, g.detectAccountsService())

	if wm == deps.WindowManagerHyprland {
		dependencies = append(dependencies, g.detectHyprlandTools()...)
	}

	if wm == deps.WindowManagerNiri {
		dependencies = append(dependencies, g.detectXwaylandSatellite())
	}

	dependencies = append(dependencies, g.detectMatugen())
	dependencies = append(dependencies, g.detectDgop())
	dependencies = append(dependencies, g.detectHyprpicker())
	dependencies = append(dependencies, g.detectClipboardTools()...)

	return dependencies, nil
}

func (g *GentooDistribution) detectXDGPortal() deps.Dependency {
	status := deps.StatusMissing
	if g.packageInstalled("sys-apps/xdg-desktop-portal-gtk") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "xdg-desktop-portal-gtk",
		Status:      status,
		Description: "Desktop integration portal for GTK",
		Required:    true,
	}
}

func (g *GentooDistribution) detectPolkitAgent() deps.Dependency {
	status := deps.StatusMissing
	if g.packageInstalled("mate-extra/mate-polkit") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "mate-polkit",
		Status:      status,
		Description: "PolicyKit authentication agent",
		Required:    true,
	}
}

func (g *GentooDistribution) detectXwaylandSatellite() deps.Dependency {
	status := deps.StatusMissing
	if g.commandExists("xwayland-satellite") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "xwayland-satellite",
		Status:      status,
		Description: "Xwayland support",
		Required:    true,
	}
}

func (g *GentooDistribution) detectAccountsService() deps.Dependency {
	status := deps.StatusMissing
	if g.packageInstalled("sys-apps/accountsservice") {
		status = deps.StatusInstalled
	}

	return deps.Dependency{
		Name:        "accountsservice",
		Status:      status,
		Description: "D-Bus interface for user account query and manipulation",
		Required:    true,
	}
}

func (g *GentooDistribution) packageInstalled(pkg string) bool {
	cmd := exec.Command("qlist", "-I", pkg)
	err := cmd.Run()
	return err == nil
}

func (g *GentooDistribution) GetPackageMapping(wm deps.WindowManager) map[string]PackageMapping {
	return g.GetPackageMappingWithVariants(wm, make(map[string]deps.PackageVariant))
}

func (g *GentooDistribution) GetPackageMappingWithVariants(wm deps.WindowManager, variants map[string]deps.PackageVariant) map[string]PackageMapping {
	packages := map[string]PackageMapping{
		"git":                    {Name: "dev-vcs/git", Repository: RepoTypeSystem},
		"ghostty":                {Name: "x11-terms/ghostty", Repository: RepoTypeSystem, UseFlags: "X wayland", AcceptKeywords: "~amd64"},
		"kitty":                  {Name: "x11-terms/kitty", Repository: RepoTypeSystem, UseFlags: "X wayland"},
		"alacritty":              {Name: "x11-terms/alacritty", Repository: RepoTypeSystem, UseFlags: "X wayland"},
		"wl-clipboard":           {Name: "gui-apps/wl-clipboard", Repository: RepoTypeSystem},
		"xdg-desktop-portal-gtk": {Name: "sys-apps/xdg-desktop-portal-gtk", Repository: RepoTypeSystem, UseFlags: "wayland X"},
		"mate-polkit":            {Name: "mate-extra/mate-polkit", Repository: RepoTypeSystem},
		"accountsservice":        {Name: "sys-apps/accountsservice", Repository: RepoTypeSystem},
		"hyprpicker":             g.getHyprpickerMapping(variants["hyprland"]),

		"quickshell":              g.getQuickshellMapping(variants["quickshell"]),
		"matugen":                 {Name: "x11-misc/matugen", Repository: RepoTypeGURU, AcceptKeywords: "~amd64"},
		"cliphist":                {Name: "app-misc/cliphist", Repository: RepoTypeGURU, AcceptKeywords: "~amd64"},
		"dms (DankMaterialShell)": g.getDmsMapping(variants["dms (DankMaterialShell)"]),
		"dgop":                    {Name: "dgop", Repository: RepoTypeManual, BuildFunc: "installDgop"},
	}

	switch wm {
	case deps.WindowManagerHyprland:
		packages["hyprland"] = g.getHyprlandMapping(variants["hyprland"])
		packages["grim"] = PackageMapping{Name: "gui-apps/grim", Repository: RepoTypeSystem}
		packages["slurp"] = PackageMapping{Name: "gui-apps/slurp", Repository: RepoTypeSystem}
		packages["hyprctl"] = g.getHyprlandMapping(variants["hyprland"])
		packages["grimblast"] = PackageMapping{Name: "grimblast", Repository: RepoTypeManual, BuildFunc: "installGrimblast"}
		packages["jq"] = PackageMapping{Name: "app-misc/jq", Repository: RepoTypeSystem}
	case deps.WindowManagerNiri:
		packages["niri"] = g.getNiriMapping(variants["niri"])
		packages["xwayland-satellite"] = PackageMapping{Name: "xwayland-satellite", Repository: RepoTypeManual, BuildFunc: "installXwaylandSatellite"}
	}

	return packages
}

func (g *GentooDistribution) getQuickshellMapping(variant deps.PackageVariant) PackageMapping {
	if forceQuickshellGit || variant == deps.VariantGit {
		return PackageMapping{Name: "gui-apps/quickshell", Repository: RepoTypeGURU, UseFlags: "-breakpad jemalloc sockets wayland layer-shell session-lock toplevel-management screencopy X pipewire tray mpris pam hyprland hyprland-global-shortcuts hyprland-focus-grab i3 i3-ipc bluetooth", AcceptKeywords: "~amd64"}
	}
	return PackageMapping{Name: "gui-apps/quickshell", Repository: RepoTypeGURU, UseFlags: "-breakpad jemalloc sockets wayland layer-shell session-lock toplevel-management screencopy X pipewire tray mpris pam hyprland hyprland-global-shortcuts hyprland-focus-grab i3 i3-ipc bluetooth", AcceptKeywords: "~amd64"}
}

func (g *GentooDistribution) getDmsMapping(_ deps.PackageVariant) PackageMapping {
	return PackageMapping{Name: "dms", Repository: RepoTypeManual, BuildFunc: "installDankMaterialShell"}
}

func (g *GentooDistribution) getHyprlandMapping(variant deps.PackageVariant) PackageMapping {
	if variant == deps.VariantGit {
		return PackageMapping{Name: "gui-wm/hyprland", Repository: RepoTypeGURU, UseFlags: "X", AcceptKeywords: "~amd64"}
	}
	return PackageMapping{Name: "gui-wm/hyprland", Repository: RepoTypeSystem, UseFlags: "X", AcceptKeywords: "~amd64"}
}

func (g *GentooDistribution) getHyprpickerMapping(_ deps.PackageVariant) PackageMapping {
	return PackageMapping{Name: "gui-apps/hyprpicker", Repository: RepoTypeGURU, AcceptKeywords: "~amd64"}
}

func (g *GentooDistribution) getNiriMapping(variant deps.PackageVariant) PackageMapping {
	if variant == deps.VariantGit {
		return PackageMapping{Name: "gui-wm/niri", Repository: RepoTypeGURU, UseFlags: "dbus screencast", AcceptKeywords: "~amd64"}
	}
	return PackageMapping{Name: "gui-wm/niri", Repository: RepoTypeSystem, UseFlags: "dbus screencast", AcceptKeywords: "~amd64"}
}

func (g *GentooDistribution) getPrerequisites() []string {
	return []string{
		"app-eselect/eselect-repository",
		"dev-vcs/git",
		"dev-build/make",
		"app-arch/unzip",
		"dev-util/pkgconf",
	}
}

func (g *GentooDistribution) InstallPrerequisites(ctx context.Context, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	prerequisites := g.getPrerequisites()
	var missingPkgs []string

	progressChan <- InstallProgressMsg{
		Phase:      PhasePrerequisites,
		Progress:   0.06,
		Step:       "Checking prerequisites...",
		IsComplete: false,
		LogOutput:  "Checking prerequisite packages",
	}

	for _, pkg := range prerequisites {
		checkCmd := exec.CommandContext(ctx, "qlist", "-I", pkg)
		if err := checkCmd.Run(); err != nil {
			missingPkgs = append(missingPkgs, pkg)
		}
	}

	_, err := exec.LookPath("go")
	if err != nil {
		g.log("go not found in PATH, will install dev-lang/go")
		missingPkgs = append(missingPkgs, "dev-lang/go")
	} else {
		g.log("go already available in PATH")
	}

	if len(missingPkgs) == 0 {
		g.log("All prerequisites already installed")
		return nil
	}

	g.log(fmt.Sprintf("Installing prerequisites: %s", strings.Join(missingPkgs, ", ")))
	progressChan <- InstallProgressMsg{
		Phase:       PhasePrerequisites,
		Progress:    0.08,
		Step:        fmt.Sprintf("Installing %d prerequisites...", len(missingPkgs)),
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: fmt.Sprintf("sudo emerge --ask=n %s", strings.Join(missingPkgs, " ")),
		LogOutput:   fmt.Sprintf("Installing prerequisites: %s", strings.Join(missingPkgs, ", ")),
	}

	args := []string{"emerge", "--ask=n", "--quiet"}
	args = append(args, missingPkgs...)
	cmdStr := fmt.Sprintf("echo '%s' | sudo -S %s", sudoPassword, strings.Join(args, " "))
	cmd := exec.CommandContext(ctx, "bash", "-c", cmdStr)
	output, err := cmd.CombinedOutput()
	if err != nil {
		g.logError("failed to install prerequisites", err)
		g.log(fmt.Sprintf("Prerequisites command output: %s", string(output)))
		return fmt.Errorf("failed to install prerequisites: %w", err)
	}
	g.log(fmt.Sprintf("Prerequisites install output: %s", string(output)))

	return nil
}

func (g *GentooDistribution) InstallPackages(ctx context.Context, dependencies []deps.Dependency, wm deps.WindowManager, sudoPassword string, reinstallFlags map[string]bool, progressChan chan<- InstallProgressMsg) error {
	progressChan <- InstallProgressMsg{
		Phase:      PhasePrerequisites,
		Progress:   0.05,
		Step:       "Checking system prerequisites...",
		IsComplete: false,
		LogOutput:  "Starting prerequisite check...",
	}

	if err := g.InstallPrerequisites(ctx, sudoPassword, progressChan); err != nil {
		return fmt.Errorf("failed to install prerequisites: %w", err)
	}

	systemPkgs, guruPkgs, manualPkgs := g.categorizePackages(dependencies, wm, reinstallFlags)

	g.log(fmt.Sprintf("CATEGORIZED PACKAGES: system=%d, guru=%d, manual=%d", len(systemPkgs), len(guruPkgs), len(manualPkgs)))

	if len(systemPkgs) > 0 {
		systemPkgNames := g.extractPackageNames(systemPkgs)
		progressChan <- InstallProgressMsg{
			Phase:      PhaseSystemPackages,
			Progress:   0.35,
			Step:       fmt.Sprintf("Installing %d system packages...", len(systemPkgs)),
			IsComplete: false,
			NeedsSudo:  true,
			LogOutput:  fmt.Sprintf("Installing system packages: %s", strings.Join(systemPkgNames, ", ")),
		}
		if err := g.installPortagePackages(ctx, systemPkgs, sudoPassword, progressChan); err != nil {
			return fmt.Errorf("failed to install Portage packages: %w", err)
		}
	}

	if len(guruPkgs) > 0 {
		g.log(fmt.Sprintf("FOUND %d GURU PACKAGES - WILL SYNC GURU REPO", len(guruPkgs)))
		progressChan <- InstallProgressMsg{
			Phase:      PhaseAURPackages,
			Progress:   0.60,
			Step:       "Syncing GURU repository...",
			IsComplete: false,
			LogOutput:  "Syncing GURU repository to fetch latest ebuilds",
		}
		g.log("ABOUT TO CALL syncGURURepo")
		if err := g.syncGURURepo(ctx, sudoPassword, progressChan); err != nil {
			g.log(fmt.Sprintf("syncGURURepo RETURNED ERROR: %v", err))
			return fmt.Errorf("failed to sync GURU repository: %w", err)
		}
		g.log("syncGURURepo COMPLETED SUCCESSFULLY")

		guruPkgNames := g.extractPackageNames(guruPkgs)
		progressChan <- InstallProgressMsg{
			Phase:      PhaseAURPackages,
			Progress:   0.65,
			Step:       fmt.Sprintf("Installing %d GURU packages...", len(guruPkgs)),
			IsComplete: false,
			LogOutput:  fmt.Sprintf("Installing GURU packages: %s", strings.Join(guruPkgNames, ", ")),
		}
		if err := g.installGURUPackages(ctx, guruPkgs, sudoPassword, progressChan); err != nil {
			return fmt.Errorf("failed to install GURU packages: %w", err)
		}
	}

	if len(manualPkgs) > 0 {
		progressChan <- InstallProgressMsg{
			Phase:      PhaseSystemPackages,
			Progress:   0.85,
			Step:       fmt.Sprintf("Building %d packages from source...", len(manualPkgs)),
			IsComplete: false,
			LogOutput:  fmt.Sprintf("Building from source: %s", strings.Join(manualPkgs, ", ")),
		}
		if err := g.InstallManualPackages(ctx, manualPkgs, sudoPassword, progressChan); err != nil {
			return fmt.Errorf("failed to install manual packages: %w", err)
		}
	}

	progressChan <- InstallProgressMsg{
		Phase:      PhaseConfiguration,
		Progress:   0.90,
		Step:       "Configuring system...",
		IsComplete: false,
		LogOutput:  "Starting post-installation configuration...",
	}

	progressChan <- InstallProgressMsg{
		Phase:      PhaseComplete,
		Progress:   1.0,
		Step:       "Installation complete!",
		IsComplete: true,
		LogOutput:  "All packages installed and configured successfully",
	}

	return nil
}

func (g *GentooDistribution) categorizePackages(dependencies []deps.Dependency, wm deps.WindowManager, reinstallFlags map[string]bool) ([]PackageMapping, []PackageMapping, []string) {
	systemPkgs := []PackageMapping{}
	guruPkgs := []PackageMapping{}
	manualPkgs := []string{}

	variantMap := make(map[string]deps.PackageVariant)
	for _, dep := range dependencies {
		variantMap[dep.Name] = dep.Variant
	}

	packageMap := g.GetPackageMappingWithVariants(wm, variantMap)

	for _, dep := range dependencies {
		if dep.Status == deps.StatusInstalled && !reinstallFlags[dep.Name] {
			continue
		}

		pkgInfo, exists := packageMap[dep.Name]
		if !exists {
			g.log(fmt.Sprintf("Warning: No package mapping for %s", dep.Name))
			continue
		}

		switch pkgInfo.Repository {
		case RepoTypeSystem:
			systemPkgs = append(systemPkgs, pkgInfo)
		case RepoTypeGURU:
			guruPkgs = append(guruPkgs, pkgInfo)
		case RepoTypeManual:
			manualPkgs = append(manualPkgs, dep.Name)
		}
	}

	return systemPkgs, guruPkgs, manualPkgs
}

func (g *GentooDistribution) extractPackageNames(packages []PackageMapping) []string {
	names := make([]string, len(packages))
	for i, pkg := range packages {
		names[i] = pkg.Name
	}
	return names
}

func (g *GentooDistribution) installPortagePackages(ctx context.Context, packages []PackageMapping, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	if len(packages) == 0 {
		return nil
	}

	packageNames := g.extractPackageNames(packages)
	g.log(fmt.Sprintf("Installing Portage packages: %s", strings.Join(packageNames, ", ")))

	for _, pkg := range packages {
		if pkg.AcceptKeywords != "" {
			if err := g.setPackageAcceptKeywords(ctx, pkg.Name, pkg.AcceptKeywords, sudoPassword); err != nil {
				return fmt.Errorf("failed to set accept keywords for %s: %w", pkg.Name, err)
			}
		}
		if pkg.UseFlags != "" {
			if err := g.setPackageUseFlags(ctx, pkg.Name, pkg.UseFlags, sudoPassword); err != nil {
				return fmt.Errorf("failed to set USE flags for %s: %w", pkg.Name, err)
			}
		}
	}

	args := []string{"emerge", "--ask=n", "--quiet"}
	args = append(args, packageNames...)

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
	return g.runWithProgress(cmd, progressChan, PhaseSystemPackages, 0.40, 0.60)
}

func (g *GentooDistribution) setPackageUseFlags(ctx context.Context, packageName, useFlags, sudoPassword string) error {
	packageUseDir := "/etc/portage/package.use"

	mkdirCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S mkdir -p %s", sudoPassword, packageUseDir))
	if output, err := mkdirCmd.CombinedOutput(); err != nil {
		g.log(fmt.Sprintf("mkdir output: %s", string(output)))
		return fmt.Errorf("failed to create package.use directory: %w", err)
	}

	useFlagLine := fmt.Sprintf("%s %s", packageName, useFlags)

	appendCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S bash -c \"echo '%s' >> %s/danklinux\"", sudoPassword, useFlagLine, packageUseDir))

	output, err := appendCmd.CombinedOutput()
	if err != nil {
		g.log(fmt.Sprintf("append output: %s", string(output)))
		return fmt.Errorf("failed to write USE flags to package.use: %w", err)
	}

	g.log(fmt.Sprintf("Set USE flags for %s: %s", packageName, useFlags))
	return nil
}

func (g *GentooDistribution) syncGURURepo(ctx context.Context, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	g.log("Enabling GURU repository...")

	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.55,
		Step:        "Enabling GURU repository...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: "sudo eselect repository enable guru",
	}

	// Enable GURU repository
	enableCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S eselect repository enable guru", sudoPassword))
	output, err := enableCmd.CombinedOutput()
	if err != nil {
		g.logError("failed to enable GURU repository", err)
		g.log(fmt.Sprintf("eselect repository enable output: %s", string(output)))
		return fmt.Errorf("failed to enable GURU repository: %w", err)
	}
	g.log(fmt.Sprintf("GURU repository enabled: %s", string(output)))

	// Sync GURU repository
	progressChan <- InstallProgressMsg{
		Phase:       PhaseSystemPackages,
		Progress:    0.57,
		Step:        "Syncing GURU repository...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: "sudo emaint sync --repo guru",
	}

	g.log("Syncing GURU repository...")
	syncCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S emaint sync --repo guru", sudoPassword))
	syncOutput, syncErr := syncCmd.CombinedOutput()
	if syncErr != nil {
		g.logError("failed to sync GURU repository", syncErr)
		g.log(fmt.Sprintf("emaint sync output: %s", string(syncOutput)))
		return fmt.Errorf("failed to sync GURU repository: %w", syncErr)
	}
	g.log(fmt.Sprintf("GURU repository synced: %s", string(syncOutput)))

	return nil
}

func (g *GentooDistribution) setPackageAcceptKeywords(ctx context.Context, packageName, keywords, sudoPassword string) error {
	checkCmd := exec.CommandContext(ctx, "portageq", "match", "/", packageName)
	if output, err := checkCmd.CombinedOutput(); err == nil && len(output) > 0 {
		g.log(fmt.Sprintf("Package %s is already available (may already be unmasked)", packageName))
		return nil
	}

	acceptKeywordsDir := "/etc/portage/package.accept_keywords"

	mkdirCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S mkdir -p %s", sudoPassword, acceptKeywordsDir))
	if output, err := mkdirCmd.CombinedOutput(); err != nil {
		g.log(fmt.Sprintf("mkdir output: %s", string(output)))
		return fmt.Errorf("failed to create package.accept_keywords directory: %w", err)
	}

	keywordLine := fmt.Sprintf("%s %s", packageName, keywords)

	checkExistingCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("grep -q '^%s ' %s/danklinux 2>/dev/null", packageName, acceptKeywordsDir))
	if checkExistingCmd.Run() == nil {
		g.log(fmt.Sprintf("Accept keywords already set for %s", packageName))
		return nil
	}

	appendCmd := exec.CommandContext(ctx, "bash", "-c",
		fmt.Sprintf("echo '%s' | sudo -S bash -c \"echo '%s' >> %s/danklinux\"", sudoPassword, keywordLine, acceptKeywordsDir))

	output, err := appendCmd.CombinedOutput()
	if err != nil {
		g.log(fmt.Sprintf("append output: %s", string(output)))
		return fmt.Errorf("failed to write accept keywords: %w", err)
	}

	g.log(fmt.Sprintf("Set accept keywords for %s: %s", packageName, keywords))
	return nil
}

func (g *GentooDistribution) installGURUPackages(ctx context.Context, packages []PackageMapping, sudoPassword string, progressChan chan<- InstallProgressMsg) error {
	if len(packages) == 0 {
		return nil
	}

	packageNames := g.extractPackageNames(packages)
	g.log(fmt.Sprintf("Installing GURU packages: %s", strings.Join(packageNames, ", ")))

	for _, pkg := range packages {
		if pkg.AcceptKeywords != "" {
			if err := g.setPackageAcceptKeywords(ctx, pkg.Name, pkg.AcceptKeywords, sudoPassword); err != nil {
				return fmt.Errorf("failed to set accept keywords for %s: %w", pkg.Name, err)
			}
		}
		if pkg.UseFlags != "" {
			if err := g.setPackageUseFlags(ctx, pkg.Name, pkg.UseFlags, sudoPassword); err != nil {
				return fmt.Errorf("failed to set USE flags for %s: %w", pkg.Name, err)
			}
		}
	}

	guruPackages := make([]string, len(packageNames))
	for i, pkg := range packageNames {
		guruPackages[i] = pkg + "::guru"
	}

	args := []string{"emerge", "--ask=n", "--quiet"}
	args = append(args, guruPackages...)

	progressChan <- InstallProgressMsg{
		Phase:       PhaseAURPackages,
		Progress:    0.70,
		Step:        "Installing GURU packages...",
		IsComplete:  false,
		NeedsSudo:   true,
		CommandInfo: fmt.Sprintf("sudo %s", strings.Join(args, " ")),
	}

	cmdStr := fmt.Sprintf("echo '%s' | sudo -S %s", sudoPassword, strings.Join(args, " "))
	cmd := exec.CommandContext(ctx, "bash", "-c", cmdStr)
	return g.runWithProgress(cmd, progressChan, PhaseAURPackages, 0.70, 0.85)
}
