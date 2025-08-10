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
    my.desktops.sway.config = "${fs.sway}/config";

    my.programs = {
      dunst = {
        enable = true;

        config = "${fs.dunst}/dunstrc";
      };

      foot = {
        enable = true;

        config = "${fs.foot}/foot.ini";
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


    fonts.fontconfig = {
      enable = true;

      defaultFonts = {
        emoji = lib.singleton "Noto Color Emoji";
        monospace = lib.singleton "Noto Sans Mono";
        serif = lib.singleton "Noto Serif";
        sansSerif = lib.singleton "Noto Sans";
      };
    };

    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
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


    home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;

      name = "Bibata-Modern-Classic";
      size = 16;

      gtk.enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;

      gtk2.extraConfig = ''
        gtk-application-prefer-dark-theme = 1
      '';

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      font = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;

      style = {
        name = "adwaita-dark";
        package = with pkgs; [
          adwaita-qt
          adwaita-qt6
        ];
      };
    };


    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "microsoft-edge.desktop" ];
      };
    };
  };
}
