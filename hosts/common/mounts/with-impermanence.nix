{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
in {
  # Define the major filesystems needed for an impermanence setup.
  fileSystems = mkIf (config.impermanence.enable == true) {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=1G" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/nix";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
  };
}
