{ pkgs, ... }:
{
    # Ignore some packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
    ];

    # KDE Plasma5 configuration
    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;
        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };
}
