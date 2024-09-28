{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  config = lib.mkMerge [
    ({ system.stateVersion = "24.05"; })
    ({
      # Set some important system values
      console.keyMap = "us";
      i18n.defaultLocale = "en_CA.UTF-8";
      time.timeZone = "America/Toronto";
    })
    ({
      # Enable relevant swap and /tmp mount configuration
      my.mounts = {
        swap.enableZram = true;
        tmp.enableTmpfs = true;
      };
    })
    ({
      # Enable networking with some additional powersavings
      # for this poor, pitiable laptop.
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
    })
    ({
      # Setup boot stuff
      my.boot.systemd-boot.enable = true;
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "noatime" ];
      };
    })
    ({
      # Enable DEs
      my.desktops.plasma.enable = true;
      my.desktops.sway.enable = true;
      my.desktops.sway.default = true;
    })
    ({
      # Enable impermanence and setup mounts
      my.persist.enable = true;
      fileSystems = {
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [ "mode=755" "noatime" "size=2G" ];
        };

        "/nix" = {
          device = "/dev/disk/by-label/store";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };
    })
  ];
}
