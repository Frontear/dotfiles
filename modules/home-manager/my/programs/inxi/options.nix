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
        default = pkgs.inxi;
        apply = inxi: pkgs.callPackage ./package.nix {
          inherit inxi;
        };

        type = with lib.types; package;
      };
    };
  };
}