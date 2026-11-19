{
  config,
  lib,
  ...
}:
let
  cfg = config.boot.lanzaboote;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = cfg.pkiBundle;
        unique = false;
      }
      {
        # Necessary for `lanzaboote.autoEnrollkeys`
        path = "/var/lib/autocrypt-enroll";
        unique = false;
      }
    ];

    boot = {
      consoleLogLevel = 3;
      loader.timeout = 0;

      kernelParams = [
        "quiet"
        "systemd.show_status=auto"
        "udev.log_level=${toString config.boot.consoleLogLevel}"
      ];

      lanzaboote = {
        pkiBundle = "/var/lib/sbctl";

        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          enable = true;

          autoReboot = true; # TODO: how much does this interrupt the user?
          includeFirmwareBuiltinKeys = true;
        };
      };
    };
  };
}