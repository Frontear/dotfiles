{
  ...
}:
{
  config = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;

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
