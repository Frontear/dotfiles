{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  config = lib.mkIf cfg.enable {
    my.programs.chromium = {
      enable = true;
      package = pkgs.microsoft-edge;
    };

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 1 [
          "cffi/browser"
        ];

        "cffi/browser" = {
          module_path = self.packages.waybar-icon.lib;

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
