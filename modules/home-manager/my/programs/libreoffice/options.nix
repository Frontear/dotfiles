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
        default = pkgs.libreoffice-stable;

        type = with lib.types; package;
      };
    };
  };
}