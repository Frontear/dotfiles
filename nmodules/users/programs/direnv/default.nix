{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkAfter mkEnableOption mkIf mkOption types;

  nix-direnv = pkgs.nix-direnv.override { nix = config.nix.package; };

  userOpts = { config, ... }: {
    options.programs.direnv = {
      enable = mkEnableOption "direnv";
      package = mkOption {
        default = pkgs.direnv;

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.direnv.enable {
      packages = [ config.programs.direnv.package ];

      programs.zsh.rc = mkAfter ''
        eval "$(${getExe config.programs.direnv.package} hook zsh)"
      '';

      file."~/.config/direnv/direnv.toml".content = (pkgs.formats.toml {}).generate "direnv-toml" (import ./config.nix config);

      file."~/.config/direnv/direnvrc".content = ''
        source ${nix-direnv}/share/nix-direnv/direnvrc
      '';
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}
