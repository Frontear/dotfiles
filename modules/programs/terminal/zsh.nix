{ ... }: ({ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    my.users.frontear.persist.files = [ "~/.local/share/zsh/zsh_history" ];

    users.extraUsers.frontear.shell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      enableBashCompletion = true;
      enableGlobalCompInit = false;

      promptInit = "";
    };

    home-manager.users.frontear = { config, ... }: {
      programs.eza = {
        enable = true;

        extraOptions = [
          "--group"
          "--group-directories-first"
          "--header"
          "--octal-permissions"
        ];

        git = true;
        icons = true;
      };

      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;

        dotDir = ".config/zsh";

        historySubstringSearch.enable = true;
        history = {
          extended = true;
          ignoreDups = true;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
        };

        # RPS1 from https://unix.stackexchange.com/a/375730
        initExtra = ''
          PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
          RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
        '';

        # TODO: plugins.{*}?, shellAliases, shellGlobalAliases
        sessionVariables.EDITOR = "nvim";

        syntaxHighlighting = {
          enable = true;

          highlighters = [ "main" "brackets" ];
        };
      };
    };
  };
})