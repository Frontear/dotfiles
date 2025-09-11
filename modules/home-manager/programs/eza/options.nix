{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.eza = {
      enable = lib.mkDefaultEnableOption "eza";
      package = lib.mkOption {
        default = pkgs.eza;

        type = with lib.types; package;
      };
    };
  };
}