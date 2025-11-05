{
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  config = {
    my.desktops.gnome.enable = true;

    services.displayManager.autoLogin.enable = true;

    environment.systemPackages = [
      inputs.nixos-facter.packages.nixos-facter
    ];

    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
  };
}