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

      waybar = {
        enable = true;

        config = "${fs.waybar}/config.jsonc";
        style = "${fs.waybar}/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      noto-fonts
      nerd-fonts.symbols-only

      brightnessctl
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


    qt = {
      enable = true;

      platformTheme.name = "gtk3";

      style = {
        name = "adwaita-dark";
        package = with pkgs; [
          adwaita-qt
          adwaita-qt6
        ];
      };
    };

    gtk = {
      enable = true;

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


    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "microsoft-edge.desktop" ];
      };
    };
  };
}
