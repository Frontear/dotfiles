{
  config,
  lib,
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
  };
}