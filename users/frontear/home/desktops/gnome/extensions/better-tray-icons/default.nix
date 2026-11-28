{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    my.desktops.gnome.extensions = with pkgs.gnomeExtensions; [
      better-tray-icons
    ];

    dconf = {
      settings = {
        "org/gnome/shell/extensions/bettertrayicons" = {
          toggle-icon-active-name = "go-up-search-symbolic";
          toggle-icon-name = "go-down-search-symbolic";

          # Show nothing on the bar, keep them all inside the tray.
          visible-icon-limit = 0;
        };
      };
    };
  };
}