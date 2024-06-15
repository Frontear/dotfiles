{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.socials.armcord;
in {
  options.frontear.programs.socials.armcord = {
    enable = mkEnableOption "opinionated armcord module";
  };

  config = mkIf cfg.enable {
    impermanence.user.directories = [ ".config/ArmCord" ];

    users.extraUsers.frontear.packages = with pkgs; [ armcord ];
  };
}