{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.nix-index;
in {
  options.my.programs.nix-index = {
    enable = lib.mkDefaultEnableOption "nix-index";
    package = lib.mkOption {
      default = pkgs.nix-index.override (prev: {
        nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (prevAttrs: {
          patches = (prevAttrs.patches or []) ++ [
            # https://github.com/nix-community/nix-index/pull/243
            ./skip-fhs-by-default.patch
          ];
        });
      });

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [ "~/.cache/nix-index" ];

    programs.command-not-found.enable = lib.mkForce false;
    programs.nix-index = {
      inherit (cfg) enable package;
    };
  };
}
