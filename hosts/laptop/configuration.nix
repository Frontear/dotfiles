{
  ...
}:
{
  imports = [
    ./hardware
    ./mounts.nix
    ./time-sync.nix
  ];

  config = {
    # Enable networking support
    my.network.networkmanager = {
      enable = true;
      enablePowerSave = true;

      dns.providers.cloudflare.enable = true;
      hosts.providers.stevenblack.enable = true;
    };

    # Enable chipset-specific power saving tunings
    # TODO: move elsewhere?
    boot.extraModprobeConfig = ''
      options iwlwifi power_level=3 power_save=1 uapsd_disable=0
      options iwlmvm power_scheme=3
    '';

    # Enable a desktop environment
    my.desktops.sway.enable = true;

    # Set locale, keymap and timezone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}
