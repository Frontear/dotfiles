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
    # TODO: de-duplicate from Niri
    stylix = {
      enable = true;

      base16Scheme = ./theme.yaml;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;

        size = 24;
      };

      fonts = {
        sizes = {
          applications = 11;
          desktop = 11;
          terminal = 11;
          popups = 11;
        };

        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };

        monospace = {
          name = "Noto Sans Mono";
          package = pkgs.noto-fonts;
        };

        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };

        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
        };
      };

      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;

        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

      image = ./assets/bg_dark.jpg;
      imageScalingMode = "fit";

      polarity = "dark";
    };

    stylix.targets = {
      fontconfig.enable = true;
      font-packages.enable = true;

      gtk.enable = true;
      qt.enable = true;

      gnome.enable = true;
    };
  };
}