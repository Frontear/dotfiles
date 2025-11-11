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
  };
}