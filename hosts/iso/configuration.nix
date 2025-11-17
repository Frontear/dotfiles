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
    my.defaults.enable = true;

    my.desktops.gnome.enable = true;

    services.displayManager.autoLogin.enable = true;

    environment.systemPackages = [
      inputs.nixos-facter.packages.nixos-facter
    ];
  };
}