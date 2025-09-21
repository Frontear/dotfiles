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
    programs.obs-studio.enable = true;

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 5 [
          "cffi/recorder"
        ];

        "cffi/recorder" = {
          module_path = pkgs.frontear.waybar-icon.lib;

          icon-name = "com.obsproject.Studio";
          on-click = "app2unit com.obsproject.Studio.desktop";
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