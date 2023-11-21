{ pkgs, ... }:
{
    # plasma5
    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;
        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        khelpcenter
    ];
}
