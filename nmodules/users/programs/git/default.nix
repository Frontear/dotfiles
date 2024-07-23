{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.git.enable = mkEnableOption "git";

    config = mkIf config.programs.git.enable {
      packages = with pkgs; [
        git
      ];

      file."~/.config/git/config".content = lib.generators.toGitINI (import ./config.nix pkgs);

      file."~/.config/git/ignore".content = ''
        .envrc
      '';
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}