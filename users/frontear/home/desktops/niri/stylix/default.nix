{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      base16Scheme = ./theme.yaml;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;

        size = 16;
      };

      fonts = {
        sizes = {
          applications = 12;
          desktop = 12;
          terminal = 10;
          popups = 12;
        };

        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-emoji;
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
    };
  };
}