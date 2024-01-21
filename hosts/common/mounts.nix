{ ... }: {
  # Defines some of the basic mounts I carry on every single system.
  fileSystems = {
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
  };
}
