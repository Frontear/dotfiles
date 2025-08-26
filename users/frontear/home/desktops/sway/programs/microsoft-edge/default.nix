{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;

  icon = "${config.gtk.iconTheme.package}/share/icons/${config.gtk.iconTheme.name}/24x24/apps/com.microsoft.Edge.svg";
in {
  config = lib.mkIf cfg.enable {
    my.programs.chromium = {
      enable = true;
      package = pkgs.microsoft-edge;
    };

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 1 [
          "image#browser"
        ];

        "image#browser" = {
          path = "${icon}";
          size = 28;
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
