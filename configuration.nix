{ lib, pkgs, ... }:
{
    _module.args = {
        username = "frontear";
        hostname = "frontear-net";
    };

    imports = [
        ./system
        ./hosts/laptop
    ];

    services.printing.enable = true;
    services.pipewire.enable = true;

    networking.firewall.enable = true;
    #networking.firewall.allowedTCPPorts = [];
    #networking.firewall.allowedUDPPorts = [];

    # TODO: environment.etc
    # TODO: environment.localBinInPath

    # TODO: fonts

    # TODO: location

    # TODO: networking

    # TODO: networking.firewall

    # clean up nix store and optimise it
    nix = {
        gc.automatic = true;
        optimise.automatic = true;
    };

    # TODO: nix.settings

    # TODO powerManagement

    # TODO: programs

    # TODO: qt

    # TODO: security.pam

    # TODO: security.polkit

    # prevent non-wheel users from even running sudo
    security.sudo.execWheelOnly = true;

    # TODO: services

    # enable sound TODO: add pipewire
    sound.enable = true;

    # TODO: swapDevices

    # TODO: system.autoUpgrade?

    # TODO: system.copySystemConfiguration?

    # Set system state version, never change this
    system.stateVersion = "23.11";

    # TODO: systemd

    # TODO: xdg.portal
}
