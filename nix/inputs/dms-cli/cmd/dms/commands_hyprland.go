package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/AvengeMedia/danklinux/internal/hyprland"
	"github.com/AvengeMedia/danklinux/internal/log"
	"github.com/spf13/cobra"
)

var hyprlandCmd = &cobra.Command{
	Use:   "hyprland",
	Short: "Hyprland utilities",
	Long:  "Utilities for working with Hyprland configuration",
}

var hyprlandKeybindsCmd = &cobra.Command{
	Use:   "keybinds",
	Short: "Parse Hyprland keybinds",
	Long:  "Parse keybinds from Hyprland configuration files",
	Run:   runHyprlandKeybinds,
}

func init() {
	hyprlandKeybindsCmd.Flags().String("path", "$HOME/.config/hypr", "Path to Hyprland config directory")
	hyprlandCmd.AddCommand(hyprlandKeybindsCmd)
}

func runHyprlandKeybinds(cmd *cobra.Command, args []string) {
	path, _ := cmd.Flags().GetString("path")

	section, err := hyprland.ParseKeys(path)
	if err != nil {
		log.Fatalf("Error parsing keybinds: %v", err)
	}

	output, err := json.Marshal(section)
	if err != nil {
		log.Fatalf("Error generating JSON: %v", err)
	}

	fmt.Fprintln(os.Stdout, string(output))
}
