{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
  fs = pkgs.callPackage ./fs {};
in {
  config = lib.mkIf cfg.enable {
    my.desktops.sway.config = "${fs}/sway/config";

    my.programs = {
      foot.enable = true;
      waybar = {
        enable = true;

        config = "${fs}/waybar/config.jsonc";
        style = "${fs}/waybar/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      brightnessctl
      perlPackages.Apppapersway
      rofi
      swayidle
      swaylock
      wl-clip-persist
    ];
  };
}
