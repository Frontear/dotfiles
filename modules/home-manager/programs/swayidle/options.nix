{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.swayidle = {
      enable = lib.mkEnableOption "swayidle";
      package = lib.mkOption {
        default = pkgs.swayidle;

        type = with lib.types; package;
      };

      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}
