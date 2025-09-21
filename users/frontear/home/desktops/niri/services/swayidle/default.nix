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
    services.swayidle = {
      enable = true;

      events = [
        {
          event = "before-sleep";
          command = "${lib.getExe' config.programs.swaylock.package "swaylock"}";
        }
      ];

      timeouts = [
        {
          timeout = 60 * 2;
          command = "${lib.getExe' config.programs.swaylock.package "swaylock"}";
        }
        {
          timeout = 60 * 5;
          command = "${lib.getExe pkgs.niri} msg output eDP-1 off";
          resumeCommand = "${lib.getExe pkgs.niri} msg output eDP-1 on";
        }
      ];
    };
  };
}