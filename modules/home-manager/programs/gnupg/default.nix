{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.gnupg;
in {
  options.my.programs.gnupg = {
    enable = lib.mkEnableOption "gnupg" // { default = true; };
    package = lib.mkOption {
      default = pkgs.gnupg;
      defaultText = "pkgs.gnupg";
      description = ''
        The gnupg package to use.
      '';

      type = with lib.types; package;
    };

    dotDir = lib.mkOption {
      default = "${config.xdg.dataHome}/gnupg";

      type = with lib.types; path;
    };

    agent = {
      enable = lib.mkEnableOption "gnupg.agent" // { default = true; };
      enableSSHSupport = lib.mkEnableOption "gnupg.agent.ssh" // { default = true; };

      pinentryPackage = lib.mkOption {
        default = pkgs.pinentry-tty;
        defaultText = "pkgs.pinentry-tty";
        description = ''
          The package which provides the desired pinentry interface.
        '';

        type = with lib.types; package;
      };

      sshKeys = lib.mkOption {
        default = [];
        description = ''
          List of GPG keygrips to expose as SSH keys.
        '';

        type = with lib.types; listOf str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      { path = lib.replaceStrings [ config.home.homeDirectory ] [ "~" ] cfg.dotDir; mode = "700"; }
      { path = "~/.ssh"; mode = "700"; }
    ];

    # https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY
    programs.ssh.enable = true;
    programs.ssh.matchBlocks.refresh-tty.match = ''
      host * exec "${lib.getExe' cfg.package "gpg-connect-agent"} UPDATESTARTUPTTY /bye"
    '';

    programs.gpg = {
      enable = true;
      package = cfg.package;

      homedir = cfg.dotDir;
    };

    services.gpg-agent = {
      enable = cfg.agent.enable;
      enableSshSupport = cfg.agent.enableSSHSupport;

      pinentryPackage = cfg.agent.pinentryPackage;

      sshKeys = cfg.agent.sshKeys;
    };
  };
}
