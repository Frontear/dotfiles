{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.programs.gnupg.enable {
    my.persist.directories = [
      { path = lib.replaceStrings [ config.home.homeDirectory ] [ "~" ] config.my.programs.gnupg.dotDir; mode = "700"; }
      { path = "~/.ssh"; mode = "700"; }
    ];

    programs.gpg = {
      enable = true;
      package = config.my.programs.gnupg.package;

      homedir = config.my.programs.gnupg.dotDir;
    };

    services.gpg-agent = {
      enable = config.my.programs.gnupg.agent.enable;
      enableSshSupport = config.my.programs.gnupg.agent.enableSSHSupport;

      pinentryPackage = config.my.programs.gnupg.agent.pinentryPackage;

      sshKeys = config.my.programs.gnupg.agent.sshKeys;
    };
  };
}