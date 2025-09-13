{
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  config = {
    networking.networkmanager.enable = true;

    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasmax11";

    services.displayManager = {
      autoLogin.enable = true;
      sddm.enable = true;
    };

    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";

    zramSwap.enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}