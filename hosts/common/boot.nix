{ pkgs, ... }:
{
    # kernel
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;

    # loader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot = {
        enable = true;

        configurationLimit = 5;
        memtest86.enable = true;
    };

    # silent
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=3" ];
    boot.kernel.sysctl = {
        "kernel.printk" = "3 3 3 3";
    };
    boot.loader.timeout = 0;
    boot.plymouth.enable = true;
}
