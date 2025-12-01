package dms

import (
	"context"
	"os"
	"os/exec"

	"github.com/AvengeMedia/danklinux/internal/config"
	"github.com/AvengeMedia/danklinux/internal/deps"
	"github.com/AvengeMedia/danklinux/internal/distros"
)

type Detector struct {
	homeDir      string
	distribution distros.Distribution
}

func (d *Detector) GetDistribution() distros.Distribution {
	return d.distribution
}

func NewDetector() (*Detector, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	logChan := make(chan string, 100)
	go func() {
		for range logChan {
		}
	}()

	osInfo, err := distros.GetOSInfo()
	if err != nil {
		return nil, err
	}

	dist, err := distros.NewDistribution(osInfo.Distribution.ID, logChan)
	if err != nil {
		return nil, err
	}

	return &Detector{
		homeDir:      homeDir,
		distribution: dist,
	}, nil
}

func (d *Detector) IsDMSInstalled() bool {
	_, err := config.LocateDMSConfig()
	return err == nil
}

func (d *Detector) GetDependencyStatus() ([]deps.Dependency, error) {
	hyprlandDeps, err := d.distribution.DetectDependencies(context.Background(), deps.WindowManagerHyprland)
	if err != nil {
		return nil, err
	}

	niriDeps, err := d.distribution.DetectDependencies(context.Background(), deps.WindowManagerNiri)
	if err != nil {
		return nil, err
	}

	// Combine dependencies and deduplicate
	depMap := make(map[string]deps.Dependency)

	for _, dep := range hyprlandDeps {
		depMap[dep.Name] = dep
	}

	for _, dep := range niriDeps {
		// If dependency already exists, keep the one that's installed or needs update
		if existing, exists := depMap[dep.Name]; exists {
			if dep.Status > existing.Status {
				depMap[dep.Name] = dep
			}
		} else {
			depMap[dep.Name] = dep
		}
	}

	// Convert map back to slice
	var allDeps []deps.Dependency
	for _, dep := range depMap {
		allDeps = append(allDeps, dep)
	}

	return allDeps, nil
}

func (d *Detector) GetWindowManagerStatus() (bool, bool, error) {
	// Reuse the existing command detection logic from BaseDistribution
	// Since all distros embed BaseDistribution, we can access it via interface
	type CommandChecker interface {
		CommandExists(string) bool
	}

	checker, ok := d.distribution.(CommandChecker)
	if !ok {
		// Fallback to direct command check if interface not available
		hyprlandInstalled := d.commandExists("hyprland") || d.commandExists("Hyprland")
		niriInstalled := d.commandExists("niri")
		return hyprlandInstalled, niriInstalled, nil
	}

	hyprlandInstalled := checker.CommandExists("hyprland") || checker.CommandExists("Hyprland")
	niriInstalled := checker.CommandExists("niri")

	return hyprlandInstalled, niriInstalled, nil
}

func (d *Detector) commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

func (d *Detector) GetInstalledComponents() []DependencyInfo {
	dependencies, err := d.GetDependencyStatus()
	if err != nil {
		return []DependencyInfo{}
	}

	isNixOS := d.isNixOS()

	var components []DependencyInfo
	for _, dep := range dependencies {
		// On NixOS, filter out the window managers themselves but keep their components
		if isNixOS && (dep.Name == "hyprland" || dep.Name == "niri") {
			continue
		}

		components = append(components, DependencyInfo{
			Name:        dep.Name,
			Status:      dep.Status,
			Description: dep.Description,
			Required:    dep.Required,
		})
	}

	return components
}

func (d *Detector) isNixOS() bool {
	_, err := os.Stat("/etc/nixos")
	if err == nil {
		return true
	}

	// Alternative check
	if _, err := os.Stat("/nix/store"); err == nil {
		// Also check for nixos-version command
		if d.commandExists("nixos-version") {
			return true
		}
	}

	return false
}

type DependencyInfo struct {
	Name        string
	Status      deps.DependencyStatus
	Description string
	Required    bool
}
