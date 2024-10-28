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
