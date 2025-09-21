{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.duf = {
      enable = lib.mkDefaultEnableOption "duf";
      package = lib.mkOption {
        default = pkgs.duf;

        type = with lib.types; package;
      };
    };
  };
}