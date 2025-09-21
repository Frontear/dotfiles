{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    xdg.configFile."niri/config.kdl".source = cfg.config;
  };
}