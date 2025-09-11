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
  imports = [
    ./stylix
    ./programs
    ./services
  ];

  config = lib.mkIf cfg.enable {
    my.desktops.sway.config = "${fs.sway}/config";

    my.programs = {
      swayosd = {
        enable = true;

        style = "${fs.swayosd}/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      perlPackages.Apppapersway
      wl-clip-persist
    ];


    my.programs = {
      element.enable = true;

      legcord.enable = true;
    };
  };
}