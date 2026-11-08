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

      # Replace `gnome-keyring` with `oo7`, a desktop independent secrets
      # implementation, as the former is unmaintained.
      gnome.gnome-keyring.enable = false;
      oo7.enable = true;

      # Replace power-profiles-daemon with TuneD, which has a shim that offers
      # PPD compatibility.
      power-profiles-daemon.enable = false;
      tuned.enable = true;
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