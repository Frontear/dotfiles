{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.direnv;
in {
  options.frontear.programs.direnv = {
    enable = mkEnableOption "opinionated direnv module.";
  };

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