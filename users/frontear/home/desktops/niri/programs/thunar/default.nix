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
    my.programs = {
      thunar.enable = true;
    };

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 2 [
          "cffi/file_manager"
        ];

        "cffi/file_manager" = {
          module_path = pkgs.frontear.waybar-icon.lib;

          icon-name = "org.xfce.thunar";
          on-click = "app2unit -- thunar.desktop";
          tooltip = false;
        };
      };
    };
  };
}