{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.neovim;

  pluginSubmodule = {
    options = {
      plugin = lib.mkOption {
        default = null;

        type = with lib.types; package;
      };

      config = lib.mkOption {
        default = "";

        type = with lib.types; lines;
      };
    };
  };
in {
  options.my.programs.neovim = {
    enable = lib.mkDefaultEnableOption "neovim";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix {
        inherit (cfg) extraBins;

        plugins = map (e: e.plugin) cfg.plugins;
      };

      type = with lib.types; package;
    };

    extraBins = lib.mkOption {
      default = [];

      type = with lib.types; listOf package;
    };

    init = lib.mkOption {
      default = "";

      type = with lib.types; lines;
    };

    plugins = lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo package (plugin: { inherit plugin; }) (submodule pluginSubmodule));
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.cache/nvim"
      "~/.local/share/nvim"
      "~/.local/state/nvim"
    ];

    xdg.configFile."nvim/init.lua".text = ''
      ${cfg.init}

      ${lib.concatStringsSep "\n" (map (e: e.config) cfg.plugins)}
    '';

    home.packages = [ cfg.package ];
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
