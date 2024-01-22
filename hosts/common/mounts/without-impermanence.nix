{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
in {
  # Defines the major filesystems needed for an non-impermanent setup.
  # /nix is not separate here because we don't need it.
  fileSystems = mkIf (config.impermanence.enable != true) {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
  };
}
