{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.desktops.hyprland;
in {
  config = mkIf cfg.enable {
    programs.light.enable = true;
    users.extraUsers.frontear.extraGroups = [ "video" ];
  };
}