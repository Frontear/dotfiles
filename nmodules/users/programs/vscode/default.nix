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
      package = mkOption {
        default = with pkgs; (vscode-with-extensions.override {
          vscodeExtensions = vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix);
        });

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.vscode.enable {
      packages = [ config.programs.vscode.package ];

      file."~/.config/Code/User/settings.json".content = (pkgs.formats.json {}).generate "vscode-settings" (import ./settings.nix);
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}
