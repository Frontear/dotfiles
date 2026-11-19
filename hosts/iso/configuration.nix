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
    my.desktops.gnome.enable = true;

    # Use the long-term variant of the XanMod kernel to ensure the ZFS kernel
    # module is not broken. It matters here a lot since the ISO is built with
    # ZFS support, and I don't really know how to remove it, nor do I think
    # I want to.
    #
    # The latest XanMod kernel that `my.defaults` sets doesn't always compile
    # with the ZFS package. That's why we use the long-term variant, which
    # should usually always have the package available since its so old.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod;

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