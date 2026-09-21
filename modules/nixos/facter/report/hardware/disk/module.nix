{
  config,
  lib,
  ...
}:
let
  # TODO: detect SATA SSDs as well.
  validDisk = lib.facter.disk.isNVMe config;
in {
  config = lib.mkIf validDisk {
    services.fstrim.enable = lib.mkDefault true;
  };
}