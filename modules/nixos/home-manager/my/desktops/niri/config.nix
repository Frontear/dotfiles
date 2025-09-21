{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    # Since Niri already uses a lot of GNOME things, let's pull the GNOME
    # polkit authentication agent as well.
    services.polkit-gnome.enable = true;

    xdg.configFile."niri/config.kdl".source = cfg.config;
  };
}