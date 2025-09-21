{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
  fs = import ./fs {
    inherit (pkgs) callPackage;
  };
in {
  imports = [
    ./stylix
    ./programs
    ./services
  ];

  config = lib.mkIf cfg.enable {
    my.desktops.niri.config = "${fs.niri}/config.kdl";

    my.programs = {
      swayosd = {
        enable = true;

        style = "${fs.swayosd}/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      app2unit
      swaybg
      wl-clip-persist
    ];


    my.programs = {
      element.enable = true;

      legcord.enable = true;
    };
  };
}