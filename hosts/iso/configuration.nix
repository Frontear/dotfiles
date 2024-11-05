{
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  config = {
    my.mounts.swap.enableZram = true;

    my.network.networkmanager = {
      enable = true;

      dns.providers.cloudflare.enable = true;
      hosts.providers.stevenblack.enable = true;
    };

    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasmax11";

    services.displayManager = {
      autoLogin.enable = true;
      sddm.enable = true;
    };

    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";

    nixpkgs.config.allowUnfree = true;
  };
}
