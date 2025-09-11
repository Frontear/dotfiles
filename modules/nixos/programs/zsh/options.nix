{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.zsh = {
      enable = lib.mkEnableOption "zsh";
      package = lib.mkOption {
        default = pkgs.zsh;

        type = with lib.types; package;
      };
    };
  };
}