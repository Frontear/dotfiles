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
      bins = lib.mkOption {
        default = [];

        type = with lib.types; listOf package;
      };

      plugins = lib.mkOption {
        default = null;

        type = with lib.types; listOf package;
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
        extraBins = cfg.extraBins ++
          (lib.flatten (map (e: e.bins) cfg.plugins));

        plugins = lib.flatten (map (e: e.plugins) cfg.plugins);
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

      type = with lib.types; listOf (coercedTo package (plugins: {
        inherit plugins;
      }) (submodule pluginSubmodule));
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/state/nvim";
      unique = false;
    }];

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