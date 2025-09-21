{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  imports = [
    ./style.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      settings = {
        top = {
          layer = "top";
          position = "top";
          margin = "4 4 0 4";
          spacing = 0;
          mode = "dock";


          modules-left = [
            "niri/workspaces"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "network"
            "wireplumber"
            "battery"
          ];


          "niri/workspaces" = {
            disable-click = true;
            current-only = true;
          };


          "clock" = {
            format = "{:%b %d %H:%M}";

            tooltip = true;
            tooltip-format = "<tt><small>{calendar}</small></tt>";

            calendar = {
              format = {
                today = "<b><u>{}</u></b>";
              };
            };
          };


          "network" = {
            format-disconnected = "󰤮";
            format-ethernet = "󰈀";
            format-linked = "󰤫";
            format-wifi = "{icon}";

            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];

            tooltip = true;
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
          };

          "wireplumber" = {
            format = "{icon}";
            format-muted = "󰝟";
            format-icons = [ "󰕿" "󰖀" "󰕾" ];

            on-click = "wpctl set-mute @DEFAULT_SINK@ toggle";

            tooltip = true;
            tooltip-format = "{volume}%";
          };

          "battery" = {
            interval = 5;

            format = "{icon}";
            format-icons = {
              full = "󱟢";
              charging = [ "󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
              discharging = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            };
          };
        };

        bottom = {
          layer = "top";
          position = "bottom";
          margin = "0 4 4 4";
          spacing = 0;
          mode = "dock";

          modules-center = lib.mkOrder 0 [];
        };
      };
    };
  };
}