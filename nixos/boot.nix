{
  pkgs,
  ...
}: {
  boot.consoleLogLevel = 0;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
  boot.loader.timeout = 0;

  hardware.cpu.intel.updateMicrocode = true;
}
