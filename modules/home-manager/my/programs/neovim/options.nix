{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.neovim;

  pluginsSubmodule = {
    options = {
      config = lib.mkOption {
        default = "";

        type = with lib.types; lines;
      };
    } // lib.genAttrs [ "bins" "plugins" ] (_: lib.mkOption {
      default = [];

      type = with lib.types; listOf package;
    });
  };
in {
  options = {
    my.programs.neovim = {
      enable = lib.mkDefaultEnableOption "neovim";

      package = lib.mkOption {
        default = pkgs.neovim-unwrapped;
        apply = neovim-unwrapped: pkgs.callPackage ./package.nix {
          inherit neovim-unwrapped;

          bins = cfg.extraBins ++ (
            cfg.plugins
            |> map (e: e.bins)
            |> lib.flatten
          );

          plugins = (
            cfg.plugins
            |> map (e: e.plugins)
            |> lib.flatten
          );

          config = pkgs.writeText "init.lua" ''
            ${cfg.extraConfig}

            ${lib.concatStringsSep "\n" (
              cfg.plugins
              |> map (e: e.config)
            )}
          '';
        };

        type = with lib.types; package;
      };


      plugins = lib.mkOption {
        default = [];

        type = with lib.types; listOf (coercedTo package (plugins: {
          inherit plugins;
        }) (submodule pluginsSubmodule));
      };

      extraBins = lib.mkOption {
        default = [];

        type = with lib.types; listOf package;
      };

      extraConfig = lib.mkOption {
        default = [];

        type = with lib.types; lines;
      };
    };
  };
}