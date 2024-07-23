{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  nix-direnv = pkgs.nix-direnv.override { nix = config.nix.package; };

  userOpts = { config, ... }: {
    options.programs.direnv = {
      enable = mkEnableOption "direnv";
    };

    config = mkIf config.programs.direnv.enable {
      packages = with pkgs; [
        direnv
      ];

      file."~/.config/direnv/direnv.toml".content = (pkgs.formats.toml {}).generate "direnv-config" (import ./config.nix config);

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