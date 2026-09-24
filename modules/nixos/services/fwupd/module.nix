{
  config,
  lib,
  ...
}:
let
  cfg = config.services.fwupd;

  usingFacter = config.hardware.facter.reportPath != null;
  isBaremetal = config.hardware.facter.detected.virtualisation.none.enable;
in {
  config = lib.mkMerge [
    (lib.mkIf (usingFacter && isBaremetal) {
      # Firmware updates only make sense if we are running on a real device.
      services.fwupd.enable = true;
    })
    (lib.mkIf cfg.enable {
      my.persist.directories = [
        {
          path = "/var/cache/fwupd";
          unique = false;
        }
        {
          path = "/var/lib/fwupd";
          unique = false;
        }
      ];
    })
  ];
}