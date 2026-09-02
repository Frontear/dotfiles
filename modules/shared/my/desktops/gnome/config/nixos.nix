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
    networking.networkmanager.enable = true;
    services.pipewire.enable = true;


    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      # Replace power-profiles-daemon with TuneD, which has a shim that offers
      # PPD compatibility.
      tuned.enable = true;
      power-profiles-daemon.enable = false;
    };

    # TODO: de-duplicate from Niri
    environment.sessionVariables = {
      "NIXOS_OZONE_WL" = 1;
    };

    environment.gnome.excludePackages = with pkgs; [
      epiphany
    ];


    services.printing.enable = true;
  };
}