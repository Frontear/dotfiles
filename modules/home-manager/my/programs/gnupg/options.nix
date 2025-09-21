{
  options,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.gnupg = {
      enable = lib.mkDefaultEnableOption "gnupg";
      package = lib.mkOption {
        default = pkgs.gnupg;

        type = with lib.types; package;
      };


      agent = {
        sshKeys = lib.mkOption {
          default = [];

          type = options.services.gpg-agent.sshKeys.type;
        };
      };
    };
  };
}