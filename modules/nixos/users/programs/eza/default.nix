{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkAfter mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.eza = {
      enable = mkEnableOption "eza";
      package = mkOption {
        default = pkgs.eza;

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.eza.enable {
      programs.zsh.rc = mkAfter ''
        alias -- ls="${getExe config.programs.eza.package} --git --group --group-directories-first --icons --header --octal-permissions"
      '';
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}
