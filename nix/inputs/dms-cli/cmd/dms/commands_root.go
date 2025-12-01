package main

import (
	"errors"
	"os"

	"github.com/AvengeMedia/danklinux/internal/distros"
	"github.com/AvengeMedia/danklinux/internal/dms"
	"github.com/AvengeMedia/danklinux/internal/log"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "dms",
	Short: "dms CLI",
	Long:  "dms is the DankMaterialShell management CLI and backend server.",
	Run:   runInteractiveMode,
}

func runInteractiveMode(cmd *cobra.Command, args []string) {
	detector, err := dms.NewDetector()
	if err != nil && !errors.Is(err, &distros.UnsupportedDistributionError{}) {
		log.Fatalf("Error initializing DMS detector: %v", err)
	} else if errors.Is(err, &distros.UnsupportedDistributionError{}) {
		log.Error("Interactive mode is not supported on this distribution.")
		log.Info("Please run 'dms --help' for available commands.")
		os.Exit(1)
	}

	if !detector.IsDMSInstalled() {
		log.Error("DankMaterialShell (DMS) is not detected as installed on this system.")
		log.Info("Please install DMS using dankinstall before using this management interface.")
		os.Exit(1)
	}

	model := dms.NewModel(Version)
	p := tea.NewProgram(model, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		log.Fatalf("Error running program: %v", err)
	}
}
