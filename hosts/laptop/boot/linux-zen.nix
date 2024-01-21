{
  pkgs,
  ...
}: {
  # Enables the usage of the linux zen kernel.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
}
