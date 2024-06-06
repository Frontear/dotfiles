# TODO: move?
{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.hyprland;
in {
  config = mkIf cfg.enable {
    impermanence.user.directories = [ ".config/ArmCord" ];

    home-manager.users.frontear = { pkgs, ... }: {
      home.packages = with pkgs; [ armcord ];
    };
  };
}