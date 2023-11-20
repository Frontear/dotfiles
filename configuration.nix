{ lib, pkgs, ... }: let
    impermanence = builtins.fetchGit { url = "https://github.com/nix-community/impermanence.git"; };
    home-manager = builtins.fetchGit { url = "https://github.com/nix-community/home-manager.git"; };
in {
    imports = [
        ./hardware-configuration.nix
        "${impermanence}/nixos.nix"
        "${home-manager}/nixos"

        ./system
    ];

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

    # setup plasma5 on system and remove some extra packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        khelpcenter
    ];

    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;
        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
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

    # use a zram device for swapping TODO: set swappiness
    zramSwap = {
        enable = true;
        priority = 100;
    };
}
