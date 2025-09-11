{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    my.services = {
      networkmanager.enable = true;
      pipewire.enable = true;
    };

    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      epiphany
    ];


    services.printing.enable = true;
  };
}