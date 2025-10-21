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
    stylix.targets.swaylock.enable = true;

    programs.swaylock = {
      enable = true;

      settings = {
        daemonize = true;
        indicator-caps-lock = true;

        indicator = true;
        clock = true;
        datestr = "%a, %b %d, %Y";

        effect-blur = "7x3";
        effect-custom = "${pkgs.frontear.sl-darken}/${pkgs.frontear.sl-darken.libPath}";
      };
    };
  };
}