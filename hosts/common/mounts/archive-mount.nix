{ ... }: {
  fileSystems."/archive" = {
    device = "/dev/disk/by-label/archive";
    fsType = "vfat";
    options = [ "noatime" ];
  };
}
