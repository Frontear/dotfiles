{
  pkgs,
  ...
}: {
  # --- BOOT
  boot = {
    consoleLogLevel = 0;
    initrd = {
      systemd.enable = false;
      verbose = false;
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
  };
  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.timeout = 0;

  # --- ETC
}
