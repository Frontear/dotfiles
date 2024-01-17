{
  pkgs,
  ...
}: {
  boot = {
    consoleLogLevel = 0;

    initrd = {
      compressor = "lz4";
      compressorArgs = [ "-l" "-9" ];

      systemd.enable = true;
      verbose = false;
    };

    kernel.sysctl = {
      "kernel.printk" = "0 0 0 0";
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 0;
    };
  };

  hardware.cpu.intel.updateMicrocode = true;
}
