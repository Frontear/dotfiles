{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.defaults;
in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Default keymap, locale, and time zone
      console.keyMap = "us";
      i18n.defaultLocale = "en_CA.UTF-8";
      time.timeZone = "America/Toronto";
    }

    (lib.mkIf cfg.useBootloader {
      # NixOS is the governing OS on the EFI partition, and Lanzaboote
      # is used for secure boot setup.
      boot.loader.efi.canTouchEfiVariables = true;
      boot.lanzaboote.enable = true;
    })

    (lib.mkIf cfg.useFilesystems {
      # The filesystem setup that is expected when you follow the README
      my.persist.enable = true;

      boot.initrd.luks.devices."crypted".device = "/dev/disk/by-partlabel/nix";

      fileSystems = {
        "/" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [ "noatime" "mode=0755" "noswap" "size=256M" ];
        };

        "/boot" = {
          device = "/dev/disk/by-partlabel/boot";
          fsType = "vfat";
          options = [ "noatime" "fmask=0022" "dmask=0022" ];
        };

        "/nix" = {
          device = "/dev/mapper/crypted";
          fsType = "btrfs";
          options = [ "noatime" "compress=zstd:15" ];
        };
      };

      # Since `/nix` is formatted as BTRFS.
      services.btrfs.autoScrub = {
        enable = true;

        fileSystems = [
          "/nix"
        ];

        interval = "weekly";
      };
    })

    (lib.mkIf cfg.useKernel {
      # XanMod kernel has Clear Linux patches
      boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
    })
  ]);
}