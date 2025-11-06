{
  config,
  lib,
  ...
}:
let
  validDisk = lib.facter.disk.isNVMe config;
in {
  # TODO: way too opinionated. This is unsuitable for here and should be dropped
  # if/when there is a proper upstream module for Intel graphics.
  config = lib.mkIf validDisk {
    services.fstrim.enable = lib.mkDefault true;
  };
}