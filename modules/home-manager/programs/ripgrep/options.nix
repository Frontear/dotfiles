{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.ripgrep = {
      enable = lib.mkDefaultEnableOption "ripgrep";
      package = lib.mkOption {
        default = pkgs.ripgrep-all;

        type = with lib.types; package;
      };
    };
  };
}
