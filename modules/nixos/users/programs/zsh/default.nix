{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) any;
  inherit (lib) mapAttrsToList mkEnableOption mkIf mkOption types;

  zdotdir = "$HOME/.config/zsh";
  file-zdotdir = "~/.config/zsh";

  histfile = "$HOME/.local/share/zsh/zsh_history";
  persist-histfile = "~/.local/share/zsh/zsh_history";

  userOpts = { config, ... }: {
    options.programs.zsh = {
      enable = mkEnableOption "zsh";
      package = mkOption {
        default = pkgs.zsh;

        type = types.package;
        internal = true;
        readOnly = true;
      };

      env = mkOption {
        default = "";
        description = ''
          Lines appended to your .zshenv
        '';

        type = types.lines;
      };

      rc = mkOption {
        default = "";
        description = ''
          Lines appended to your .zshrc
        '';

        type = types.lines;
      };
    };

    config = mkIf config.programs.zsh.enable {
      shell = pkgs.zsh;

      persist.files = [
        persist-histfile
      ];

      file = {
        "~/.zshenv".content = ''
          export ZDOTDIR="${zdotdir}"

          ${config.programs.zsh.env}
        '';

        "${file-zdotdir}/.zshrc".content = ''
          PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
          RPS1='%B%(?.%F{green}.%F{red})%?%f%b'

          HISTSIZE="10000"
          SAVEHIST="10000"

          HISTFILE="${histfile}";
          mkdir -p "$(dirname "$HISTFILE")"

          ${config.programs.zsh.rc}

          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          ZSH_AUTOSUGGEST_STRATEGY=(history)
          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
          ZSH_HIGHLIGHT_HIGHLIGHTERS+=("main" "brackets")
        '';
      };
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };

  config = mkIf (any (cfg: cfg.enable) (mapAttrsToList (_: v: v.programs.zsh) config.my.users)) {
    programs.zsh = {
      enable = true;

      enableBashCompletion = true;
      enableCompletion = true;
      enableGlobalCompInit = true;

      promptInit = "";
    };
  };
}