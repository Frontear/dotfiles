{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.fastfetch = {
      enable = lib.mkDefaultEnableOption "fastfetch";
      package = lib.mkOption {
        default = pkgs.fastfetch;

        type = with lib.types; package;
      };
    };
  };
}