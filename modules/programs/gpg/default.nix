{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.gpg;
in {
  options.frontear.programs.gpg = {
    enable = mkEnableOption "opinionated gpg module.";
  };

  config = mkIf cfg.enable {
    impermanence.user.directories = [
      ".local/share/gnupg"
      ".ssh"
    ];

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
}