{ config, pkgs, lib, ... }:
let
  inherit (lib) getExe mkIf;

  cfg = config.frontear.programs.desktops.hyprland;
in {
  config = mkIf cfg.enable {
    impermanence.system.directories = [
      {
        directory = "/var/cache/tuigreet";
        user = "greeter";
        group = "greeter";
        mode = "0755";
      }
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${getExe pkgs.greetd.tuigreet} --cmd ${getExe config.programs.hyprland.package} --time --remember --remember-session --asterisks";
      };
    };
  };
}