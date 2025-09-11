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

      libreoffice.enable = true;
    };
  };
}