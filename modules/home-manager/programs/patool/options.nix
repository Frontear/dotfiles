{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.patool = {
      enable = lib.mkDefaultEnableOption "patool";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {};

        type = with lib.types; package;
      };
    };
  };
}
