{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce mkIf mkMerge;
in {
  options.my.system.boot.systemd-boot.enable = mkEnableOption "systemd-boot";

  config = mkIf config.my.system.boot.systemd-boot.enable (mkMerge [
    {
      # Set systemd-boot to be the default boot loader for this system.
      boot.loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot.enable = true;
        systemd-boot.editor = mkForce false; # security purposes
      };
    }
    {
      # Silences logging and other verbosity during login.
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
    }
  ]);
}