{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.waybar = {
      enable = lib.mkEnableOption "waybar";
      package = lib.mkOption {
        default = pkgs.waybar;

        type = with lib.types; package;
      };
    } // lib.genAttrs [ "config" "style" ] (_: lib.mkOption {
      type = with lib.types; path;
    });
  };
}
