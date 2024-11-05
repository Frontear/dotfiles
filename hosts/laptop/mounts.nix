{
  ...
}:
{
  config = {
    my.boot.systemd-boot.enable = true;
    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
      options = [ "noatime" "fmask=0022" "dmask=0022" ];
    };

    my.persist.enable = true;
    fileSystems = {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "noatime" "size=256M" ];
      };

      # chattr +C /nix/store (prevent copy-on-write)
      # chattr +m /nix/persist (prevent compression)
      "/nix" = {
        device = "/dev/disk/by-partlabel/nix";
        fsType = "btrfs";
        options = [ "noatime" "compress=zstd:15" ];
      };
    };

    services.btrfs.autoScrub = {
      enable = true;

      fileSystems = [
        "/nix"
      ];

      interval = "weekly";
    };

    my.mounts.swap.enableZram = true;
    my.mounts.tmp.enableTmpfs = true;
  };
}
