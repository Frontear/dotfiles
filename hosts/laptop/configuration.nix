{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware
  ];

  config = {
    # Use the latest xanmod kernel, mainly for the Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    # Enable networking support
    my.network.networkmanager.enable = true;

    # Enable a desktop environment
    my.desktops.sway.enable = true;

    # Set locale, keymap and timezone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}
