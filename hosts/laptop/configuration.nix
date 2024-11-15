{
  ...
}:
{
  imports = [
    ./hardware
  ];

  config = {
    # Enable networking support
    my.network.networkmanager = {
      enable = true;
      enablePowerSave = true;

      dns.providers.cloudflare.enable = true;
      hosts.providers.stevenblack.enable = true;
    };

    # Enable a desktop environment
    my.desktops.sway.enable = true;

    # Set locale, keymap and timezone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}
