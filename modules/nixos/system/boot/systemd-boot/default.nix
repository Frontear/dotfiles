{
  config,
  lib,
  ...
}:
let
  cfg = config.my.boot.systemd-boot;
in {
  options.my.boot.systemd-boot = {
    enable = lib.mkEnableOption "systemd-boot";

    touchEfi = lib.mkEnableOption "systemd-boot.touchEfi" // { default = true; };

    editor = lib.mkEnableOption "systemd-boot.editor";
    silent = lib.mkEnableOption "systemd-boot.silent" // { default = true; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.touchEfi {
      boot.loader.efi.canTouchEfiVariables = true;
    })
    {
      boot.loader.systemd-boot = {
        enable = true;
        editor = cfg.editor;
      };
    }
    (lib.mkIf cfg.silent {
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
    })
  ]);
}
