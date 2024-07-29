{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.git = {
      enable = mkEnableOption "git";
      package = mkOption {
        default = pkgs.git;

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.git.enable {
      packages = [ config.programs.git.package ];

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