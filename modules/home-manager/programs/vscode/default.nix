{
  config,
  lib,
  pkgs,
  ...
}:
let
  formats-json = pkgs.formats.json {};
in {
  options.my.programs.vscode = {
    enable = lib.mkEnableOption "vscode";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix { vscodeExtensions = config.my.programs.vscode.extensions; };
      defaultText = "<wrapped-drv>";
      description = ''
        The vscode package to use.
      '';

      type = with lib.types; package;
    };

    config = lib.mkOption {
      default = {};
      description = ''
        VSCode configuration.
      '';

      type = formats-json.type;
    };

    extensions = lib.mkOption {
      default = [];
      description = ''
        List of vscode extensions to install.
      '';

      type = with lib.types; listOf package;
    };
  };

  config = lib.mkIf config.my.programs.vscode.enable {
    home.packages = [ config.my.programs.vscode.package ];

    xdg.configFile."Code/User/settings.json".source = formats-json.generate "settings-json" config.my.programs.vscode.config;
  };
}