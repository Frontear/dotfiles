{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.gnupg;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      config.programs.gpg.homedir
      "~/.ssh"
    ];


    # https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY
    programs.ssh = lib.mkIf (cfg.agent.sshKeys != []) {
      enable = true;

      matchBlocks.refresh-tty.match = ''
        host * exec "${lib.getExe' cfg.package "gpg-connect-agent"} UPDATESTARTUPTTY /bye"
      '';
    };


    programs.gpg = {
      inherit (cfg)
        enable
        package
        ;

      homedir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      inherit (cfg.agent)
        sshKeys
        ;

      enable = true;
      enableSshSupport = lib.mkIf (cfg.agent.sshKeys != []) true;

      pinentry.package = pkgs.pinentry-tty;
    };
  };
}
