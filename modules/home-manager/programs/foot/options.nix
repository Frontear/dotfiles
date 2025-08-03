{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.foot = {
      enable = lib.mkEnableOption "foot";

      package = lib.mkOption {
        default = pkgs.foot;

        type = with lib.types; package;
      };


      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}
