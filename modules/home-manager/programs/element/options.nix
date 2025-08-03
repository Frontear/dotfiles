{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.element = {
      enable = lib.mkEnableOption "element";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {};

        type = with lib.types; package;
      };
    };
  };
}
