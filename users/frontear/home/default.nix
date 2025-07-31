{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./desktops
    ./neovim
    #./vscode
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    # Prevent TERM capabilities leaking into a shitty ssh
    "ssh" = "TERM= ssh";
  };

  my.programs = {
    cheat = {
      enable = true;

      settings = {
        editor = "nvim";
        colorize = true;
        style = "onedark";
        formatter = "terminal256";
        pager = "less";
      };
    };

    direnv = {
      enable = true;

      config = {
        whitelist.prefix = [ "${config.home.homeDirectory}/Documents" ];
      };
    };

    eza = {
      enable = true;

      extraOptions = [
        "--git"
        "--group"
        "--group-directories-first"
        "--icons"
        "--header"
        "--octal-permissions"
      ];
    };

    git = {
      enable = true;

      config = {
        user.email = "contact@frontear.dev";
        user.name = "Ali Rizvi";
        user.signingKey = "4BC247743ACFF25E";

        commit.gpgSign = true;
        tag.gpgSign = true;

        merge.tool = "nvimdiff3";

        # https:/dandavision.github.io/delta
        core.pager = "${lib.getExe pkgs.delta}";
        interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only";
        delta.line-numbers = true;

        init.defaultBranch = "main";
      };

      ignores = [
        ".envrc"
      ];
    };

    gnupg = {
      enable = true;

      agent = {
        enable = true;
        enableSSHSupport = true;

        sshKeys = [ "3DB8367E2C04F74909B7F39ABA22959A22314C10" ];
      };
    };

    zsh = {
      enable = true;

      history = {
        save = 10000;
        size = 10000;
      };

      plugins = {
        autosuggestions = {
          enable = true;
          strategy = [ "history" ];
        };

        syntax-highlighting = {
          enable = true;
          highlighters = [ "main" "brackets" ];
        };
      };

      promptInit = ''
        PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
        RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
      '';
    };
  };
}
