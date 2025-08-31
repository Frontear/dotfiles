{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.vscode;

  formats-json = pkgs.formats.json {};
in {
  options.my.programs.vscode = {
    enable = lib.mkEnableOption "vscode";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix { vscodeExtensions = cfg.extensions; };
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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."Code/User/settings.json".source = formats-json.generate "settings-json" cfg.config;
  };
}
