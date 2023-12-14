{ pkgs, ... }: {
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
    ];

    # TODO: evaluate necessity
    qt = {
        enable = true;
        platformTheme = "kde";
    };

    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;

        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };

    xdg.portal.enable = true;
    # xdg.portal.config = {};
    # xdg.portal.extraPortals = with pkgs; [
    #     xdg-desktop-portal-hyprland
    # ];
}
