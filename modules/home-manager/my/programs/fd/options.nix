{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.fd = {
      enable = lib.mkDefaultEnableOption "fd";
      package = lib.mkOption {
        default = pkgs.fd;

        type = with lib.types; package;
      };
    };
  };
}