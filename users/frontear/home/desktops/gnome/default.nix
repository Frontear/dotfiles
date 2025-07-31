{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    my.programs = {
      chromium = {
        enable = true;
        package = pkgs.google-chrome;
      };

      libreoffice.enable = true;
    };
  };
}
