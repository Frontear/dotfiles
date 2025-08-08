{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.dunst = {
      enable = lib.mkEnableOption "dunst";
      package = lib.mkOption {
        default = pkgs.dunst;

        type = with lib.types; package;
      };

      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}
