{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) any replaceStrings;
  inherit (lib) getExe' mapAttrsToList mkEnableOption mkIf mkOption types;

  # TODO: generate in Nix
  hash = "d.1uzwshierbzk3ym6i45au4jk";
  gnupghome = "~/.local/share/gnupg";

  userOpts = { config, ... }: {
    options.programs.gpg.enable = mkEnableOption "gpg";

    config = mkIf config.programs.gpg.enable {
      persist.directories = [
        { path = gnupghome; mode = "700"; }
        { path = "~/.ssh"; mode = "700"; }
      ];

      file."${gnupghome}/sshcontrol".content = ''
        AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2
      '';

      file."~/.config/systemd/user/gpg-agent.service.d/override.conf".content = ''
        [Service]
        Environment="GNUPGHOME=${replaceStrings [ "~" ] [ config.homeDirectory ] gnupghome}"
      '';

      file."~/.config/systemd/user/gpg-agent.socket.d/override.conf".content = ''
        [Socket]
        ListenStream=
        ListenStream=%t/gnupg/${hash}/S.gpg-agent
      '';

      file."~/.config/systemd/user/gpg-agent-ssh.socket.d/override.conf".content = ''
        [Socket]
        ListenStream=
        ListenStream=%t/gnupg/${hash}/S.gpg-agent.ssh
      '';

      programs.zsh.env = ''
        export GNUPGHOME="${replaceStrings [ "~" ] [ "$HOME" ] gnupghome}"
        export SSH_AUTH_SOCK="$(${getExe' pkgs.gnupg "gpgconf"} --list-dirs agent-ssh-socket)"
      '';
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };

  config = mkIf (any (cfg: cfg.enable) (mapAttrsToList (_: v: v.programs.gpg) config.my.users)) {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;

      pinentryPackage = pkgs.pinentry-tty;
    };
  };
}
