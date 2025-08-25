{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
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
            "sway/workspaces"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "network"
            "wireplumber"
            "battery"
          ];


          "sway/workspaces" = {
            disable-scroll = true;
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

          wireplumber = {
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

          # TODO: move these into their own respective modules.
          modules-center = [
            "custom/icon#browser"
            "custom/icon#file_manager"
          ];


          "custom/icon#browser" = {
            format = "󰇩";
            on-click = "uwsm app microsoft-edge";
            tooltip = false;
          };

          "custom/icon#file_manager" = {
            format = "󰉋";
            on-click = "uwsm app thunar";
            tooltip = false;
          };
        };
      };

      style = pkgs.callPackage ./style {};
    };
  };
}
