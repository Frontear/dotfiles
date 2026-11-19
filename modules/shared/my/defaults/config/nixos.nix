{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.defaults;
in {
  config = lib.mkIf cfg.enable {
    # Default keymap, locale, and time zone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";

    # XanMod kernel has Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };
}