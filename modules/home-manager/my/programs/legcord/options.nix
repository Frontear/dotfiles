{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.legcord = {
      enable = lib.mkEnableOption "legcord";
      package = lib.mkOption {
        default = pkgs.legcord;

        type = with lib.types; package;
      };
    };
  };
}