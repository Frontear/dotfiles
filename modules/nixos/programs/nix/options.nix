{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.nix = {
      enable = lib.mkDefaultEnableOption "nix";
      package = lib.mkOption {
        default = pkgs.lix;
        apply = nix: pkgs.callPackage ./package.nix {
          inherit nix;
        };

        type = with lib.types; package;
      };
    };
  };
}
