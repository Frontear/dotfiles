{ ... }: ({ config, lib, pkgs, ... }:
let
  inherit (lib) getExe' mkBefore mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    my.users.frontear.persist.directories = [
      "~/.local/share/gnupg"
      "~/.ssh"
    ];

    my.users.frontear.programs.zsh.rc = mkBefore ''
      export GPG_TTY="$(tty)"
      ${getExe' pkgs.gnupg "gpg-connect-agent"} updatestartuptty /bye > /dev/null
    '';

    my.users.frontear.programs.zsh.env = ''
      export GNUPGHOME="$HOME/.local/share/gnupg"

      if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$(${getExe' pkgs.gnupg "gpgconf"} --list-dirs agent-ssh-socket)"
      fi
    '';

    home-manager.users.frontear = { config, pkgs, ... }: {
      programs.gpg = {
        enable = true;

        homedir = "${config.xdg.dataHome}/gnupg";
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;

        pinentryPackage = pkgs.pinentry-tty;

        sshKeys = [ "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2" ];
      };
    };
  };
})