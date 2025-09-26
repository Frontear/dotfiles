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
        default = pkgs.element-desktop;
        apply = element-desktop: pkgs.callPackage ./package.nix {
          inherit element-desktop;
        };

        type = with lib.types; package;
      };
    };
  };
}