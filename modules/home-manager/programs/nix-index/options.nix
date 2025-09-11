{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.nix-index = {
      enable = lib.mkDefaultEnableOption "nix-index";
      package = lib.mkOption {
        default = pkgs.nix-index;

        type = with lib.types; package;
      };
    };
  };
}