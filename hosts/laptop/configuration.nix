{
  pkgs,
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

    # Use the latest xanmod kernel, mainly for the Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    # Enable a desktop environment
    my.desktops.sway.enable = true;

    # Grab the `libimobiledevice` suite of tools.
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      ifuse
      idevicerestore
      libimobiledevice
    ];

    # Set locale, keymap and timezone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}
