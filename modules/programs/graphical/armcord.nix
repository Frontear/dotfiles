{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.graphical;
in {
  config = mkIf cfg.enable {
    impermanence.user.directories = [ ".config/ArmCord" ];

    users.extraUsers.frontear.packages = with pkgs; [ armcord ];
  };
}