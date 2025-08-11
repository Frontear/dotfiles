{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
  fs = import ./fs {
    inherit (pkgs) callPackage;
  };
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      base16Scheme = ./base16.yaml;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;

        size = 16;
      };

      fonts = {
        sizes = {
          terminal = 9;
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

      image = ./fs/sway/backgrounds/bg_dark.jpg;
      imageScalingMode = "fit";

      polarity = "dark";
    };

    stylix.targets = {
      fontconfig.enable = true;
      font-packages.enable = true;

      foot.enable = true;

      gtk.enable = true;
      qt.enable = true;
    };

    my.desktops.sway.config = "${fs.sway}/config";

    programs = {
      foot.enable = true;
      foot.settings = {
        cursor = {
          style = "beam";
          unfocused-style = "none";
          blink = "yes";
          beam-thickness = "1.0";
        };

        key-bindings = {
          search-start = "Control+f";
        };

        search-bindings = {
          find-prev = "Up";
          find-next = "Down";
        };
      };
    };

    my.programs = {
      dunst = {
        enable = true;

        config = "${fs.dunst}/dunstrc";
      };

      rofi = {
        enable = true;

        config = "${fs.rofi}/config.rasi";
        theme = "${fs.rofi}/theme.rasi";
      };

      swayidle = {
        enable = true;

        config = "${fs.swayidle}/config";
      };

      swayosd = {
        enable = true;

        style = "${fs.swayosd}/style.css";
      };

      waybar = {
        enable = true;

        config = "${fs.waybar}/config.jsonc";
        style = "${fs.waybar}/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      perlPackages.Apppapersway
      wl-clip-persist
    ];


    my.programs = {
      chromium = {
        enable = true;
        package = pkgs.microsoft-edge;
      };

      element.enable = true;

      legcord.enable = true;

      thunar.enable = true;
    };


    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "microsoft-edge.desktop" ];
      };
    };
  };
}
