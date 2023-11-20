{ lib, pkgs, ... }: let
    _impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    _home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
    _module.args = {
        username = "frontear";
        hostname = "frontear-net";
        impermanence = _impermanence;
        home-manager = _home-manager;
    };

    imports = [
        "${_impermanence}/nixos.nix"
        "${_home-manager}/nixos"

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

    # set some files to persist from impermanence
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"

            "/var/db/sudo/lectured"
            "/var/log"
        ];
        files = [
            "/etc/machine-id" # needed for /var/log, as it keeps files based on machine-id
        ];
    };

    # TODO: fonts

    # adds va-api/vdapu drivers for OpenGL
    hardware.opengl.extraPackages = with pkgs; [ intel-media-driver intel-ocl ];

    # hdd/ssd temp sensors?
    hardware.sensor.hddtemp = {
        enable = true;
        drives = [ "/dev/nvme0n1" ];
    };

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
