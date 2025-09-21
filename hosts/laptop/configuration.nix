{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware
  ];

  config = {
    specialisation.gnome.configuration = {
      services.auto-cpufreq.enable = lib.mkForce false;


      my.desktops = {
        niri.enable = lib.mkForce false;
        gnome.enable = true;
      };
    };

    # Use the latest xanmod kernel, mainly for the Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    # Enable a desktop environment
    my.desktops.niri.enable = true;

    # Set locale, keymap and timezone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}