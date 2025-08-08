{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.rofi;
in {
  options = {
    my.programs.rofi = {
      enable = lib.mkEnableOption "rofi";
      package = lib.mkOption {
        default = pkgs.rofi-wayland;
        apply = pkg: pkgs.callPackage ./package.nix {
          rofi = pkg;

          extraArgs = "-config ${cfg.config} -theme ${cfg.theme}";
        };

        type = with lib.types; package;
      };
    } // lib.genAttrs [ "config" "theme" ] (_: lib.mkOption {
      type = with lib.types; path;
    });
  };
}
