{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    my.programs.legcord.enable = true;

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 4 [
          "cffi/discord"
        ];

        "cffi/discord" = {
          module_path = pkgs.frontear.waybar-icon.lib;

          icon-name = "discord";
          on-click = "app2unit legcord.desktop";
          tooltip = false;
        };
      };
    };
  };
}