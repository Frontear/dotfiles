# https://wiki.archlinux.org/title/Silent_boot
{
    ...
}: {
    boot = {
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernel.sysctl = {
            "kernel.printk" = "0 0 0 0";
        };
        kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
        loader.timeout = 0;
    };
}
