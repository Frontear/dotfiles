{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
in {
  # Defines some of the basic mounts I carry on every single system.
  fileSystems = mkMerge [
    (mkIf config.impermanence.enable {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "mode=755" "noatime" "size=1G" ];
      };
    })
    ({
      "/archive" = {
        device = "/dev/disk/by-label/archive";
        fsType = "btrfs";
        options = [ "compress=zstd:15" ];
      };

      "/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "noatime" ];
      };

      "/nix" = {
        device = "/dev/disk/by-label/nix";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };
    })
  ];
}
