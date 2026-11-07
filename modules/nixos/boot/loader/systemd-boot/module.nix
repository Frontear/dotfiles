{
  config,
  lib,
  ...
}:
let
  cfg = config.boot.loader.systemd-boot;
in {
  config = lib.mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Silent_boot
    boot = {
      consoleLogLevel = 3;
      loader.timeout = 5;

      kernelParams = [
        "quiet"
        "systemd.show_status=auto"
        "udev.log_level=${toString config.boot.consoleLogLevel}"
      ];
    };
  };
}