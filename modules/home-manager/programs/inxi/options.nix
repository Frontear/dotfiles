{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.inxi = {
      enable = lib.mkDefaultEnableOption "inxi";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {};

        type = with lib.types; package;
      };
    };
  };
}
