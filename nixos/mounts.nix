{
  ...
}: {
  fileSystems = {
    "/archive" = {
      device = "/dev/disk/by-label/archive";
      fsType = "btrfs";
      options = [ "compress=zstd:15" ];
    };
  };
}
