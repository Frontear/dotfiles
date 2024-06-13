{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.plasma;
in {
  options.frontear.programs.plasma = {
    enable = mkEnableOption "opinionated plasma module.";
  };

  config = mkIf cfg.enable {
    impermanence.user.directories = [
      ".config"
      ".local"
    ];

    programs.dconf.enable = true;

    services.xserver = {
      enable = true;

      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}