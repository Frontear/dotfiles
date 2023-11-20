{ pkgs, ... }:
{
    # setup plasma5 as my desktop environment "compositor"?
    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;
        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };

    # dont install some plasma5 packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        khelpcenter
    ];
}
