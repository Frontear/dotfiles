{
  lib,
  pkgs,
  ...
}:
let
  fmt = pkgs.formats.json { };
in {
  options = {
    my.programs.dms = {
      enable = lib.mkEnableOption "DankMaterialShell";

      session = lib.mkOption {
        default = {};

        type = fmt.type;
      };

      settings = lib.mkOption {
        default = {};

        type = fmt.type;
      };
    };
  };
}