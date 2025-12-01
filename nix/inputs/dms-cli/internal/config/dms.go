package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// LocateDMSConfig searches for DMS installation following XDG Base Directory specification
func LocateDMSConfig() (string, error) {
	var searchPaths []string

	configHome := os.Getenv("XDG_CONFIG_HOME")
	if configHome == "" {
		if homeDir, err := os.UserHomeDir(); err == nil {
			configHome = filepath.Join(homeDir, ".config")
		}
	}

	if configHome != "" {
		searchPaths = append(searchPaths, filepath.Join(configHome, "quickshell", "dms"))
	}

	searchPaths = append(searchPaths, "/usr/share/quickshell/dms")

	configDirs := os.Getenv("XDG_CONFIG_DIRS")
	if configDirs == "" {
		configDirs = "/etc/xdg"
	}

	for _, dir := range strings.Split(configDirs, ":") {
		if dir != "" {
			searchPaths = append(searchPaths, filepath.Join(dir, "quickshell", "dms"))
		}
	}

	for _, path := range searchPaths {
		shellPath := filepath.Join(path, "shell.qml")
		if info, err := os.Stat(shellPath); err == nil && !info.IsDir() {
			return path, nil
		}
	}

	return "", fmt.Errorf("could not find DMS config (shell.qml) in any valid config path")
}
