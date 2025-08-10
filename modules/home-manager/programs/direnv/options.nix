{
  options,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.direnv = {
      enable = lib.mkDefaultEnableOption "direnv";
      package = lib.mkOption {
        default = pkgs.direnv;

        type = with lib.types; package;
      };


      config = lib.mkOption {
        default = {};

        type = options.programs.direnv.config.type;
      };
    };
  };
}
