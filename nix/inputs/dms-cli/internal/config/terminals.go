package config

import _ "embed"

//go:embed embedded/ghostty.conf
var GhosttyConfig string

//go:embed embedded/ghostty-colors.conf
var GhosttyColorConfig string

//go:embed embedded/kitty.conf
var KittyConfig string

//go:embed embedded/kitty-theme.conf
var KittyThemeConfig string

//go:embed embedded/kitty-tabs.conf
var KittyTabsConfig string

//go:embed embedded/alacritty.toml
var AlacrittyConfig string

//go:embed embedded/alacritty-theme.toml
var AlacrittyThemeConfig string
