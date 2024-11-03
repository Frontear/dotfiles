{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./neovim
    ./sway
    #./vscode
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    # Prevent TERM capabilities leaking into a shitty ssh
    "ssh" = "TERM= ssh";
  };

  home.packages = with pkgs; [
    dig
    hyperfine
  ];

  my.programs = {
    armcord.enable = true;

    direnv = {
      enable = true;

      config = {
        whitelist.prefix = [ "${config.home.homeDirectory}/Documents" ];
      };
    };

    element.enable = true;

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
        user.email = "perm-iterate-0b@icloud.com";
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

    libreoffice = {
      enable = true;

      dictionaries = with pkgs.hunspellDicts; [
        en_CA
        en_US
      ];

      fonts = [ pkgs.corefonts ];
    };

    microsoft-edge = {
      enable = true;
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
