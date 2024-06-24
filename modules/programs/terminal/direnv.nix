{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    home-manager.users.frontear = { config, ... }: {
      programs.direnv = {
        enable = true;

        config = {
          whitelist = {
            prefix = [ "${config.home.homeDirectory}/Documents/projects" ];
          };
        };

        nix-direnv.enable = true;
      };
    };
  };
}