{ pkgs, ... }: {
  imports = [
    ../eza
  ];

  # System
  environment.persistence."/nix/persist".users.frontear = {
    files = [
      # TODO: turbo bugged, pls fix
      #"${config.home-manager.users.frontear.programs.zsh.history.path}"
    ];
  };

  programs.zsh = {
    enable = true;

    enableBashCompletion = true;
    enableCompletion = true;

    # Let HM manage these
    enableGlobalCompInit = false;
    promptInit = "";
  };

  users.users.frontear.shell = pkgs.zsh;

  # User
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

      enableAutosuggestions = true;
      enableCompletion = true;

      dotDir = ".config/zsh";

      history = {
        # TODO: these things are ??
        extended = true;
        ignoreDups = false;

        # path = ".local/state/zsh/zsh_history";
      };

      historySubstringSearch.enable = true;

      # RPS1 from https://unix.stackexchange.com/a/375730
      initExtra = ''

      PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
      RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
      '';

      # TODO: plugins.{*}?, shellAliases, shellGlobalAliases
      sessionVariables = {
        EDITOR = "nvim";
      };

      syntaxHighlighting = {
        enable = true;

        highlighters = [ "main" "brackets" ];
      };
    };
  };
}