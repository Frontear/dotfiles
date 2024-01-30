{
  pkgs,
  ...
}: {
  # Use linux zen
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Use systemd-boot
  boot.loader.efi.canTouchEfiVariables = true; # no other OS on here, this is fine
  boot.loader.systemd-boot.enable = true;
}
