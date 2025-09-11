{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.desktops.sway = {
      enable = lib.mkEnableOption "sway";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {
          sway = pkgs.swayfx;
        };

        type = with lib.types; package;
      };
    };
  };
}