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
      foot = {
        enable = true;

        config = "${fs.foot}/foot.ini";
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
      rofi
      wl-clip-persist
    ];


    my.programs = {
      chromium = {
        enable = true;
        package = pkgs.microsoft-edge;
      };

      element.enable = true;

      legcord.enable = true;
    };


    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "microsoft-edge.desktop" ];
      };
    };
  };
}
