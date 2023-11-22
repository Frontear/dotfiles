{ lib, pkgs, ... }:
{
    imports = [
        ./hosts/laptop
    ];

    fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
            meslo-lgs-nf
        ];
        fontDir.enable = true;
    };

    location.provider = "geoclue2";

    nix = {
        gc.automatic = true;
        optimise.automatic = true;
    };

    powerManagement = {
        enable = true;
        cpuFreqGovernor = "powersave";
        cpufreq.max = 3000000;
    };

    # TODO: programs

    # TODO: qt

    # TODO: security.pam
    # TODO: security.pam.services.??.gnupg

    # TODO: security.polkit

    # TODO: security.wrappers ?

    security.sudo.execWheelOnly = true;

    # TODO: services

    # Set system state version, never change this
    system.stateVersion = "23.11";

    systemd.services."NetworkManager-wait-online".enable = false;

    # TODO: systemd.tmpfiles

    xdg.portal = {
        enable = true;
    };
}
