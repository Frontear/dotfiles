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
    my.defaults = {
      # The ISO comes with the ZFS kernel module, which usually isn't able to
      # work against the latest kernels. Since this option sets the kernel
      # to XanMod latest, disable it.
      useKernel = false;
    };

    my.desktops.gnome.enable = true;

    services.displayManager.autoLogin.enable = true;

    environment.systemPackages = [
      inputs.nixos-facter.packages.nixos-facter
    ];

    # Running `sudo nixos-install` on the live ISO can fail when `use-cgroups`
    # is enabled. By proxy, `auto-allocate-uids` fails to work without cgroups,
    # so we need to disable both.
    nix.settings = {
      auto-allocate-uids = lib.mkForce false;
      use-cgroups = lib.mkForce false;
    };

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