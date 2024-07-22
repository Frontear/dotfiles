{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.vscode = {
      enable = mkEnableOption "vscode";
      finalPackage = mkOption {
        default = with pkgs; (vscode-with-extensions.override {
          vscodeExtensions = vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix);
        });
        description = '''';
        type = types.package;
        readOnly = true;
        internal = true;
      };
    };

    config = mkIf config.programs.vscode.enable {
      packages = [
        config.programs.vscode.finalPackage
      ];

      file."~/.config/Code/User/settings.json".content = (pkgs.formats.json {}).generate "vscode-settings" (import ./settings.nix);
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}