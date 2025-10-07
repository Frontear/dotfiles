{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./desktops
    ./programs
  ];

  home.stateVersion = "24.11";

  programs = {
    direnv = {
      enable = true;

      config = {
        global.strict_env = true;

        whitelist.prefix = [
          "${config.home.homeDirectory}/Documents"
        ];
      };
    };

    git = {
      extraConfig = {
        user.email = "contact@frontear.dev";
        user.name = "Ali Rizvi";
        user.signingKey = "4BC247743ACFF25E";

        merge.tool = "nvimdiff3";

        # https:/dandavision.github.io/delta
        core.pager = "${lib.getExe pkgs.delta}";
        interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only";
        delta.line-numbers = true;
      };
    };

    zsh = {
      initContent = ''
        PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
        RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
      '';

      autosuggestion = {
        enable = true;
        strategy = [ "history" ];
      };

      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
    };
  };

  my.programs = {
    gnupg = {
      enable = true;

      agent.sshKeys = [
        "3DB8367E2C04F74909B7F39ABA22959A22314C10"
      ];
    };
  };
}