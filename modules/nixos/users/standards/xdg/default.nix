{
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption mkOrder types;

  userOpts = { config, ... }: {
    options.standards.xdg.enable = mkEnableOption "xdg" // { default = true; };

    config = mkIf config.standards.xdg.enable {
      persist.directories = [
        "~/Desktop"
        "~/Documents"
        "~/Downloads"
        "~/Music"
        "~/Pictures"
        "~/Public"
        "~/Templates"
        "~/Videos"
      ];

      # mkBefore = mkOrder 500
      # https://wiki.archlinux.org/title/XDG_Base_Directory
      programs.zsh.env = mkOrder 1 ''
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CACHE_HOME="$HOME/.cache"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_STATE_HOME="$HOME/.local/state"
      '';
    };
  };
in {
  options = {
    my.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
    };
  };
}
