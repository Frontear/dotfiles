{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;

  userOpts = { config, ... }: {
    options.programs.vscode.enable = mkEnableOption "vscode";

    config = mkIf config.programs.vscode.enable {
      packages = with pkgs; [
        (vscode-with-extensions.override {
          vscodeExtensions = import ./extensions.nix extensions;
        })
      ];

      file."~/.config/Code/User/settings.json".content = (pkgs.formats.json {}).generate "vscode-settings" (import ./settings.nix);
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}