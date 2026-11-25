{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.parsec = {
      enable = lib.mkEnableOption "parsec";
      package = lib.mkOption {
        default = pkgs.parsec-bin;

        type = with lib.types; package;
      };
    };
  };
}