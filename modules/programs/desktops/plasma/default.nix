{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;

  cfg = config.frontear.programs.desktops.plasma;
in {
  options.frontear.programs.desktops.plasma = {
    enable = mkEnableOption "opinionated plasma module.";
  };

  config = mkIf cfg.enable {
    frontear.programs.browsers.microsoft-edge.enable = mkDefault true;
    frontear.programs.editors.vscode.enable = mkDefault true;
    frontear.programs.socials.armcord.enable = mkDefault true;
    frontear.system.sound.enable = mkDefault true;

    impermanence.user.directories = [
      ".config"
      ".local"
    ];

    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    programs.dconf.enable = true;

    services = {
      desktopManager.plasma6.enable = true;

      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
    };
  };
}