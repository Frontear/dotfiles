{
  options,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.git = {
      enable = lib.mkDefaultEnableOption "git";
      package = lib.mkOption {
        default = pkgs.gitFull;

        type = with lib.types; package;
      };


      config = lib.mkOption {
        default = {};

        type = options.programs.git.extraConfig.type;
      };
    };
  };
}
