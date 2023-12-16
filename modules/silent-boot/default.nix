# https://wiki.archlinux.org/title/Silent_boot
{
    ...
}: {
    boot.consoleLogLevel = 0;
    boot.initrd.systemd.enable = true;
    boot.initrd.verbose = false;
    boot.kernel.sysctl = {
        "kernel.printk" = "0 0 0 0";
    };
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
    boot.loader.timeout = 0;
}
