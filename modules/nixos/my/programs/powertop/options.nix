{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.powertop = {
      enable = lib.mkDefaultEnableOption "powertop";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {};
        description = ''
          The powertop package to use.
        '';

        type = with lib.types; package;
      };
    };
  };
}