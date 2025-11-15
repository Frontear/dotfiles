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
    my.programs.microsoft-edge.enable = true;

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "com.microsoft.Edge.desktop" ];
      };
    };
  };
}