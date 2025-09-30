{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    my.programs = {
      microsoft-edge.enable = true;
      legcord.enable = true;
      libreoffice.enable = true;
    };
  };
}