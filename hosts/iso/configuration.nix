{
  inputs,
  modulesPath,
  lib,
  pkgs,
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

    # Override `defaultPackages` to remove a couple of unnecessary packages.
    # Mainly removing `pkgs.firefox` (since we have Microsoft Edge), and
    # `pkgs.vim` and `pkgs.nano` (since we have Neovim).
    #
    # see: https://github.com/NixOS/nixpkgs/blob/66303478819d00a1929e59dd576b74542e7b18f7/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix#L42
    environment.defaultPackages = lib.mkForce (with pkgs; [
      rsync
      gparted
    ]);
  };
}