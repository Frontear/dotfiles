{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.swayosd = {
      enable = lib.mkEnableOption "swayosd";
      package = lib.mkOption {
        default = pkgs.swayosd;

        type = with lib.types; package;
      };


      style = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}
