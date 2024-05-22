{ outputs, config, lib, pkgs, ... }:
# TODO: race conditions b/w import and let
let
  home = config.users.extraUsers.frontear.home;
  dataHome = config.home-manager.users.frontear.xdg.dataHome;

  histPath = "${dataHome}/zsh/zsh_history";
  histPathPersist = lib.removePrefix "${home}/" histPath;
in {
  imports = [
    outputs.nixosModules.impermanence

    ./eza.nix
  ];

  # System
  impermanence = { user.files = [ histPathPersist ]; };

  programs.zsh = {
    enable = true;

    enableBashCompletion = true;
    enableCompletion = true;

    # Let HM manage these
    enableGlobalCompInit = false;
    promptInit = "";
  };

  users.extraUsers.frontear.shell = pkgs.zsh;

  # User
  home-manager.users.frontear = { config, ... }: {
    programs.zsh = {
      enable = true;

      enableCompletion = true;

      autosuggestion.enable = true;

      dotDir = ".config/zsh";

      history = {
        # TODO: these things are ??
        extended = true;
        ignoreDups = false;

        path = histPath;
      };

      historySubstringSearch.enable = true;

      # RPS1 from https://unix.stackexchange.com/a/375730
      initExtra = ''

        PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
        RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
      '';

      # TODO: plugins.{*}?, shellAliases, shellGlobalAliases
      sessionVariables = { EDITOR = "nvim"; };

      syntaxHighlighting = {
        enable = true;

        highlighters = [ "main" "brackets" ];
      };
    };
  };
}
