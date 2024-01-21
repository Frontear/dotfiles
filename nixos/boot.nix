{
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
}
