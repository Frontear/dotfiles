{ inputs, pkgs, ... }: {
  # System
  nixpkgs.overlays = [ inputs.waybar.overlays.default ];

  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "CascadiaCode" ]; }) ];

  # User
  home-manager.users.frontear = { config, lib, ... }: {
    programs.waybar.enable = true;

    xdg.configFile."waybar/config" = {
      text = ''
        {
          "layer": "top",
          // output
          "position": "top",
          "height": 30,
          // width
          // margin
          // margin-<top|left|bottom|right>
          "spacing": 4,
          "name": "hyprbar",
          // mode
          "start_hidden": false,
          // modifier-reset
          "exclusive": true,
          "fixed-center": true,
          "passthrough": false,
          "ipc": false,
          // id
          // include
          "reload_style_on_change": true,

          "modules-left": [
            "hyprland/workspaces"
          ],
          "hyprland/workspaces": {
            "active-only": false,
            "all-outputs": false,
            "format": "{id}",
            // format-icons
            "persistent-workspaces": {
              "*": [ 1 ]
            }
            // show-special
            // sort-by
            // window-rewrite
            // window-rewrite-default
            // format-window-separator
            // move-to-monitor
            // ignore-workspaces
          },
          "modules-center": [
            "hyprland/window"
          ],
          "hyprland/window": {
            "format": "{title}",
            // rewrite
            "separate-outputs": true,
          },
          "modules-right": [
            "network",
            "wireplumber",
            "backlight", // maybe backlight/slider
            "battery",
            "clock"
          ],
          "network": {
            // interface
            "interval": 120,
            // family
            "format": "?",
            "format-ethernet": "󰈀",
            "format-wifi": "{icon}",
            // format-linked
            "format-disconnected": "󰤮",
            "format-icons": [ "󰤯", "󰤟", "󰤢", "󰤥", "󰤨" ],
            // rotate
            // max-length
            // on-click
            // on-click-middle
            // on-click-right
            // on-scroll-up
            // on-scroll-down
            // smooth-scrolling-threshold
            "tooltip": true,
            "tooltip-format": "?",
            "tooltip-format-ethernet": "{essid}@{frequency}GHz\n{ipaddr}@{gwaddr}\n {bandwidthDownBytes}\t {bandwidthUpBytes}",
            "tooltip-format-wifi": "{essid}@{frequency}GHz ({signalStrength}%)\n{ipaddr}@{gwaddr}\n {bandwidthDownBytes}\t {bandwidthUpBytes}",
            "tooltip-format-disconnected": "no connection"
          },
          "wireplumber": {
            "format": "{icon}",
            "format-muted": "󰖁",
            "format-icons": [ "󰕿", "󰖀", "󰕾" ],
            // rotate
            // states
            // max-length
            "scroll-step": 1.0,
            // on-click
            // on-click-middle
            // on-click-right
            // on-scroll-up
            // on-scroll-down
            "tooltip": true,
            "tooltip-format": "{node_name}\n{volume}%",
            "max-volume": 100.0,
            "reverse-scrolling": 1
          },
          "backlight": {
            "interval": 1,
            "format": "{icon}",
            "format-icons": [ "󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨" ],
            // max-length
            // rotate
            // states
            // on-click
            // on-click-middle
            // on-click-right
            // on-scroll-up
            // on-scroll-down
            // smooth-scrolling-threshold
            // reverse-scrolling
            // reverse-mouse-scrolling
            "scroll-step": 1.0,
            "tooltip": true,
            "tooltip-format": "{percent}%"
          },
          "battery": {
            // bat
            // adapter
            "design-capacity": "false",
            // full-at
            "interval": 120,
            // states
            "format": "?",
            "format-full": "󱟢",
            // "format-discharging": [ "󱃍", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" ],
            "format-discharging": "{icon} D",
            // "format-charging": [ "󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅" ],
            "format-charging": "{icon} C",
            "format-icons": [ "󱃍", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" ],
            "format-time": "{H}:{M}",
            // max-length
            // rotate
            // on-click
            // on-click-middle
            // on-click-right
            // on-scroll-up
            // on-scroll-down
            // smooth-scrolling-threshold
            "tooltip": true,
            "tooltip-format": "{capacity}%\n{timeTo}",
            // weighted-average
            // bat-compatibility
          },
          "clock": {
            "interval": 60,
            "format": "{:%H:%M}",
            // timezone
            // timezones
            // locale
            // max-length
            // rotate
            // on-click
            // on-click-middle
            // on-click-right
            // on-scroll-up
            // on-scroll-down
            // smooth-scrolling-threshold
            // "tooltip": true,
            // "tooltip-format": "{:%a %b %d} @ {:%I:%M %P}"
          }
        }
      '';
    };

    #xdg.configFile."waybar/style.css" =
    #let
    #  drv = pkgs.stdenv.mkDerivation {
    #    name = "style-css";

    #    src = ./.;

    #    buildInputs = with pkgs; [ sassc ];

    #    buildPhase = ''
    #    sassc $src/style.scss style.css
    #    '';

    #    installPhase = ''
    #    mkdir -p $out
    #    cp style.css $out
    #    '';
    #  };
    #in {
    #  #source = "${drv}/style.css";
    #};
  };
}
