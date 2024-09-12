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
      # Setup boot stuff
      my.boot.systemd-boot.enable = true;
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "noatime" ];
      };
    })
    ({
      # Set some important system values
      console.keyMap = "us";
      i18n.defaultLocale = "en_CA.UTF-8";
      time.timeZone = "America/Toronto";
    })
    ({
      # Enable DEs
      my.desktops.plasma.enable = true;
      my.desktops.sway.enable = true;
      my.desktops.sway.default = true;
    })
    ({
      # Enable impermanence
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
    ({
      # Unsorted stuff
      boot.kernelPackages = pkgs.linuxPackages_latest;
      my.persist.directories = [ "/var/lib/systemd/backlight" ];
      my.mounts.swap.enable = true;
      my.network.networkmanager.enable = true;
    })
  ];
}
