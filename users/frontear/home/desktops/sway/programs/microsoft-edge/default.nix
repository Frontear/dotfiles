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
    my.programs.microsoft-edge.enable = true;

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 1 [
          "cffi/browser"
        ];

        "cffi/browser" = {
          module_path = pkgs.frontear.waybar-icon.lib;

          icon-name = "com.microsoft.Edge";
          on-click = "uwsm app com.microsoft.Edge.desktop";
          tooltip = false;
        };
      };
    };

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "com.microsoft.Edge.desktop" ];
      };
    };
  };
}
