{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.libreoffice = {
      enable = lib.mkEnableOption "libreoffice";
      package = lib.mkOption {
        default = pkgs.libreoffice-fresh;

        type = with lib.types; package;
      };
    };
  };
}