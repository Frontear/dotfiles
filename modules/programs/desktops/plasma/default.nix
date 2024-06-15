{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.desktops.plasma;
in {
  imports = [
    ./pipewire.nix
  ];

  options.frontear.programs.desktops.plasma = {
    enable = mkEnableOption "opinionated plasma module.";
  };

  config = mkIf cfg.enable {
    impermanence.user.directories = [
      ".config"
      ".local"
    ];

    programs.dconf.enable = true;

    services = {
      desktopManager.plasma6.enable = true;

      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
    };
  };
}