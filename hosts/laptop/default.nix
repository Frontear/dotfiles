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
      # Systemd Boot
      my.boot.systemd-boot.enable = true;
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "noatime" ];
      };

      # Root Mounts
      my.persist.enable = true;
      fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "mode=755" "noatime" "size=2G" ];
      };

      fileSystems."/nix" = {
        device = "/dev/disk/by-label/store";
        fsType = "ext4";
        options = [ "noatime" ];
      };

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
