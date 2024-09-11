{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
{
  home.stateVersion = "24.11";

  # TODO: remove
  my.persist.directories = [
    "~/.config"
    "~/.local"
  ];

  my.desktops.sway = {
    enable = osConfig.my.desktops.sway.enable;
    extraPackages = with pkgs; [
      foot
      rofi
      swayidle
      swaylock
    ];

    fonts = [ (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; }) ];

    config = import ./sway/config.nix;

    programs.waybar = {
      enable = true;

      config = import ./sway/waybar/config.nix;
      style = import ./sway/waybar/style.nix;
    };
  };

  my.programs = {
    armcord.enable = true;

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
        user.email = "perm-iterate-0b@icloud.com";
        user.name = "Ali Rizvi";
        user.signingKey = "BCB5CEFDE22282F5";

        commit.gpgSign = true;
        tag.gpgSign = true;

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

        sshKeys = [ "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2" ];
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

    vscode = {
      enable = true;

      config = import ./vscode/settings.nix;
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./vscode/extensions.nix);
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
