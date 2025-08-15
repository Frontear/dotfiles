{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  config = lib.mkIf cfg.enable {
    services.swayidle = {
      enable = true;

      timeouts = [
        {
          timeout = 60 * 2;
          command = "swaylock";
        }
        {
          timeout = 60 * 5;
          command = "swaymsg output * dpms off";
          resumeCommand = "swaymsg output * dpms on";
        }
      ];
    };
  };
}
