{ ... }: ({ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.system.boot;
in {
  options.frontear.system.boot = {
    enable = mkEnableOption "opinionated boot module.";
  };

  config = mkIf cfg.enable rec {
    # Silent boot
    boot.consoleLogLevel = 3;
    boot.kernelParams = [ "quiet" "udev.log_level=${builtins.toString boot.consoleLogLevel}" ];
    boot.initrd.verbose = false;
    boot.initrd.systemd.enable = true;
    boot.loader.timeout = 0;

    # Use systemd-boot
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;

    # Use memtest86
    boot.loader.systemd-boot.memtest86.enable = true;
  };
})