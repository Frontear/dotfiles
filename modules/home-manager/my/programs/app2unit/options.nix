{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.app2unit = {
      enable = lib.mkEnableOption "app2unit";

      package = lib.mkOption {
        default = pkgs.app2unit;
        apply = app2unit: pkgs.callPackage ./package {
          inherit app2unit;
        };

        type = with lib.types; package;
      };
    };
  };
}