{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) toString;
  inherit (lib) mkIf;
in {
  config = mkIf config.boot.loader.systemd-boot.enable {
    # https://wiki.archlinux.org/title/Silent_boot
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.initrd.systemd.enable = true;
    boot.loader.timeout = 0;

    boot.kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "udev.log_level=${toString config.boot.consoleLogLevel}"
    ];
  };
}