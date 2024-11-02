{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  config = lib.mkMerge [
    {
      my.persist.enable = lib.mkForce false;
      fileSystems = {
        "/" = lib.mkForce {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [ "noatime" "size=1G" ];
        };

        "/boot" = lib.mkForce {
          device = "/dev/disk/by-label/EFI";
          fsType = "vfat";
          options = [ "noatime" "fmask=0022" "dmask=0022" ];
        };

        # chattr +C /nix/store (prevent copy-on-write)
        "/nix" = lib.mkForce {
          device = "/dev/disk/by-label/nix";
          fsType = "btrfs";
          options = [ "noatime" "compress=zstd:15" "subvol=nix" ];
        };

        # chattr +m /nix/persist (prevent compression)
        "/nix/persist" = lib.mkForce {
          device = "/dev/disk/by-label/nix";
          fsType = "btrfs";
          options = [ "subvol=persist" ];
        };
      };
    }
    {
      my.boot.systemd-boot.enable = true;
      my.persist.enable = true;

      # Miscellaneous Mounts
      my.mounts.swap.enableZram = true;
      my.mounts.tmp.enableTmpfs = true;

      # Networking
      my.network.networkmanager = {
        enable = true;
        enablePowerSave = true;

        dns.providers.cloudflare.enable = true;
        hosts.providers.stevenblack.enable = true;
      };

      boot.extraModprobeConfig = ''
        options iwlwifi power_level=3 power_save=1 uapsd_disable=0
        options iwlmvm power_scheme=3
      '';

      # System Locale, Keyboard, Timezone
      console.keyMap = "us";
      i18n.defaultLocale = "en_CA.UTF-8";
      time.timeZone = "America/Toronto";

      # Desktop Environments
      my.desktops.sway.enable = true;
    }
    { system.stateVersion = "24.05"; }
  ];
}
