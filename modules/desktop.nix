{ pkgs, ... }: {
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
    ];

    # TODO: evaluate necessity
    qt.enable = true;
    qt.platformTheme = "kde";

    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;

        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };
}
