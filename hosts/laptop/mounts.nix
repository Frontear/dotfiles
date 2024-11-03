{
  lib,
  ...
}:
{
  config = {
    my.boot.systemd-boot.enable = true;
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "noatime" "fmask=0022" "dmask=0022" ];
    };

    my.persist.enable = lib.mkForce false;
    fileSystems = {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "noatime" "size=256M" ];
      };

      # chattr +C /nix/store (prevent copy-on-write)
      "/nix" = {
        device = "/dev/disk/by-label/nix";
        fsType = "btrfs";
        options = [ "noatime" "compress=zstd:15" "subvol=nix" ];
      };

      # chattr +m /nix/persist (prevent compression)
      "/nix/persist" = {
        device = "/dev/disk/by-label/nix";
        fsType = "btrfs";
        options = [ "subvol=persist" ];
      };
    };

    my.mounts.swap.enableZram = true;
    my.mounts.tmp.enableTmpfs = true;
  };
}
