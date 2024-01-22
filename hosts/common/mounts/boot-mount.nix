{ ... }: {
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "noatime" ];
  };
}
