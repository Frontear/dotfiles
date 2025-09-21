{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
  fs = pkgs.callPackage ./fs {};
in {
  config = lib.mkIf cfg.enable {
    my.programs.swayosd = {
      enable = true;

      style = "${fs}/style.css";
    };
  };
}