package config

import _ "embed"

//go:embed embedded/hyprland.conf
var HyprlandConfig string
