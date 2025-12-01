# Adding New Linux Distributions

This guide explains how to add support for new Linux distributions to the dankdots installer using the new consolidated architecture.

## Architecture Overview

The codebase uses a simple, consolidated approach where each distribution is completely self-contained:

- **All-in-One** (`internal/distros/{distro}.go`) - Complete distribution implementation
- **Auto-Registration** - Distributions register themselves via `init()` functions
- **Shared Base** - Common functionality inherited from `BaseDistribution`

## Adding Support

### Method 1: Use Existing Implementation (Derivatives)

For distros that are derivatives (like CachyOS being Arch-based), you can register them to use an existing implementation.

**Example: Adding CachyOS (Arch-based)**

```go
// internal/distros/arch.go - add to the init function
func init() {
    Register("arch", "#1793D1", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewArchDistribution(config, logChan)
    })
    Register("cachyos", "#318CE7", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewArchDistribution(config, logChan) // CachyOS uses Arch implementation but different color
    })
}
```

That's it! CachyOS now uses Arch's detection and installation logic.

**Example: Adding Ubuntu derivatives**

```go
// internal/distros/ubuntu.go (after you create it)
func init() {
    Register("ubuntu", "#E95420", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewUbuntuDistribution(config, logChan)
    })
    Register("kubuntu", "#0079C1", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewUbuntuDistribution(config, logChan) // Kubuntu uses Ubuntu implementation but different color
    })
    Register("xubuntu", "#2F5BEA", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewUbuntuDistribution(config, logChan) // Xubuntu uses Ubuntu implementation but different color
    })
    Register("pop", "#48B9C7", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewUbuntuDistribution(config, logChan) // Pop!_OS uses Ubuntu implementation but different color
    })
}
```

### Method 2: Create New Implementation

For entirely new distribution families, create a complete implementation:

**Example: Adding openSUSE**

Create `internal/distros/opensuse.go`:

```go
package distros

import (
    "context"
    "os/exec"
    "strings"

    "github.com/AvengeMedia/danklinux/internal/deps"
    "github.com/AvengeMedia/danklinux/internal/installer"
)

func init() {
    Register("opensuse-leap", "#73BA25", func(config DistroConfig, logChan chan<- string) Distribution {
        return NewOpenSUSEDistribution(config, logChan)
    })
    Register("opensuse-tumbleweed", "#73BA25", func(config DistroConfig, logChan chan<- string) Distribution {
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

func (o *OpenSUSEDistribution) GetPackageManager() PackageManagerType {
    return PackageManagerZypper
}

func (o *OpenSUSEDistribution) GetPackageMapping(wm deps.WindowManager) map[string]PackageMapping {
    return map[string]PackageMapping{
        "git":      {Name: "git", Repository: RepoTypeSystem},
        "ghostty":  {Name: "ghostty", Repository: RepoTypeManual}, // Build from source
        "kitty":    {Name: "kitty", Repository: RepoTypeSystem},
        // ... map all required packages to openSUSE equivalents
    }
}

func (o *OpenSUSEDistribution) DetectDependencies(ctx context.Context, wm deps.WindowManager) ([]deps.Dependency, error) {
    return o.DetectDependenciesWithTerminal(ctx, wm, deps.TerminalGhostty)
}

func (o *OpenSUSEDistribution) DetectDependenciesWithTerminal(ctx context.Context, wm deps.WindowManager, terminal deps.Terminal) ([]deps.Dependency, error) {
    var dependencies []deps.Dependency
    
    // Use base methods for common functionality
    dependencies = append(dependencies, o.detectDMS())
    dependencies = append(dependencies, o.detectSpecificTerminal(terminal))
    dependencies = append(dependencies, o.detectGit())
    // ... add openSUSE-specific detection
    
    return dependencies, nil
}

func (o *OpenSUSEDistribution) InstallPackages(ctx context.Context, dependencies []deps.Dependency, wm deps.WindowManager, sudoPassword string, reinstallFlags map[string]bool, progressChan chan<- installer.InstallProgressMsg) error {
    // Implement installation logic using zypper
    // Use o.InstallManualPackages() for source builds
    return nil
}

func (o *OpenSUSEDistribution) InstallPrerequisites(ctx context.Context, sudoPassword string, progressChan chan<- installer.InstallProgressMsg) error {
    // Install build tools, enable repositories, etc.
    return nil
}

func (o *OpenSUSEDistribution) packageInstalled(pkg string) bool {
    cmd := exec.Command("rpm", "-q", pkg)
    err := cmd.Run()
    return err == nil
}
```

## Repository Types

The system supports these repository types:

- `RepoTypeSystem` - Main system repository (zypper, apt, dnf, pacman)
- `RepoTypeAUR` - Arch User Repository  
- `RepoTypeCOPR` - Fedora COPR
- `RepoTypePPA` - Ubuntu PPA
- `RepoTypeManual` - Build from source

## Package Manager Support

To add a new package manager, add it to `internal/distros/interface.go`:

```go
const (
    PackageManagerPacman PackageManagerType = "pacman"
    PackageManagerDNF    PackageManagerType = "dnf"
    PackageManagerAPT    PackageManagerType = "apt"
    PackageManagerZypper PackageManagerType = "zypper"
    PackageManagerPortage PackageManagerType = "portage" // Add new ones here
)
```

## Testing Your Implementation

1. Build: `go build -o dankdots ./cmd/main.go`
2. Test on target distribution
3. Verify all packages detect and install correctly
4. Test both window managers (Hyprland, Niri)
5. Test both terminals (Ghostty, Kitty)

## Detection Process

The system automatically detects supported distributions by:

1. Reading `/etc/os-release` for the `ID` field
2. Looking up the ID in the distribution registry
3. Creating an instance using the registered constructor function

No hardcoded lists to maintain - everything is driven by the registry!

## Benefits of New Architecture

- ✅ **Single file per distro** - All logic in one place
- ✅ **Auto-registration** - No factory methods to update
- ✅ **Shared functionality** - Inherit common features
- ✅ **No duplication** - Manual builds and fonts are shared
- ✅ **Easy derivatives** - One line to support a new derivative

## Contributing

1. Fork the repository
2. Create your distribution file in `internal/distros/`  
3. Test thoroughly on your target distribution
4. Submit a pull request with example output

The maintainers will review and provide feedback. Thank you for expanding dankdots support!