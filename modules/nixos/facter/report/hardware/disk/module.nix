{
  config,
  lib,
  ...
}:
let
  usingFacter = config.facter.reportPath != null;

  hasSSD =
    lib.any (disk: disk.driver == "nvme") config.facter.report.hardware.disk;
in {
  config = lib.mkIf (usingFacter && hasSSD) {
    services.fstrim.enable = lib.mkDefault true;
  };
}