{
  config,
  lib,
  ...
}:
let
  inherit (builtins) any;
  inherit (lib) mapAttrsToList mkEnableOption mkForce mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.nix-index.enable = mkEnableOption "nix-index" // { default = true; };

    config = mkIf config.programs.nix-index.enable {
      persist.directories = [
        "~/.cache/nix-index"
      ];
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };

  config = mkIf (any (cfg: cfg.enable) (mapAttrsToList (_: v: v.programs.nix-index) config.my.users)) {
    programs.command-not-found.enable = mkForce false;
    programs.nix-index.enable = true;
  };
}