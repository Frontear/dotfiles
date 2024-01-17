{
  ...
}: {
  fileSystems = {
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

    # TODO: should /nix definition be here or in ./impermanence.nix?
    "/nix" = {
      device = "/dev/disk/by-label/nix";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
  };
}
