{
  lib,
  pkgs,
  ...
}:
let
  fmt = pkgs.formats.json {};
in {
  options = {
    my.programs.vscode = {
      enable = lib.mkEnableOption "vscode";

      extensions = lib.mkOption {
        default = [];

        type = with lib.types; listOf package;
      };

      packages = lib.mkOption {
        default = _: [];

        type = with lib.types; functionTo (listOf package);
      };

      settings = lib.mkOption {
        default = {};

        type = fmt.type;
      };
    };
  };
}