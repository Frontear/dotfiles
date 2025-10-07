{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.vscode;
  fmt = pkgs.formats.json {};
in {
  options = {
    my.programs.vscode = {
      enable = lib.mkEnableOption "vscode";

      package = lib.mkOption {
        default = pkgs.vscode;
        apply = vscode: pkgs.callPackage ./package.nix {
          inherit vscode;

          withExtensions = cfg.extensions;
        };

        type = with lib.types; package;
      };

      extensions = lib.mkOption {
        default = [];

        type = with lib.types; listOf package;
      };

      settings = lib.mkOption {
        default = {};

        type = fmt.type;
      };
    };
  };
}