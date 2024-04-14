{ outputs, config, lib, pkgs, ... }:
# TODO: race conditions b/w import and let
let
  home = config.users.users.${config.main-user.name}.home;
  dataHome = config.home-manager.users.${config.main-user.name}.xdg.dataHome;

  histPath = "${dataHome}/zsh/zsh_history";
  histPathPersist = lib.removePrefix "${home}/" histPath;
in {
  imports = [
    outputs.nixosModules.impermanence
    outputs.nixosModules.main-user

    ./eza.nix
  ];

  # System
  impermanence = {
    user.files = [
      histPathPersist
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

  users.users.${config.main-user.name}.shell = pkgs.zsh;

  # User
  home-manager.users.${config.main-user.name} = { config, ... }: {
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