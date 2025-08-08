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
    my.audio.pipewire.enable = true;
    my.network.networkmanager.enable = true;

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
