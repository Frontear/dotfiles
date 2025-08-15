{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;
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
        datestr = "%a, %B %d, %Y";

        effect-blur = "16x2";
      };
    };
  };
}
