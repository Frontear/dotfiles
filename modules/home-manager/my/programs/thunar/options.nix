{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.thunar = {
      enable = lib.mkEnableOption "thunar";
      package = lib.mkOption {
        default = pkgs.thunar;

        type = with lib.types; package;
      };
    };
  };
}