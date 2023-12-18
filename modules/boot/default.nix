{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf mkMerge;
in {
    options = {
        boot = {
            fast = mkEnableOption ''
            speed up the boot process to land into the system faster
            '';
            silent = mkEnableOption ''
            completely silence boot output from both kernel and NixOS scripts
            '';
        };
    };

    config = mkMerge [
        (mkIf config.boot.fast {
            # Poor optimization, barely does anything.
            # Better solutions would include somehow delaying hardware init or smthing
            boot.initrd.compressor = "cat";
        })

        (mkIf config.boot.silent {
            # https://wiki.archlinux.org/title/Silent_boot
            boot = {
                consoleLogLevel = 0;
                initrd = {
                    verbose = false;
                    systemd.enable = true;
                };
                kernel.sysctl = {
                    "kernel.printk" = "0 0 0 0";
                };
                kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
                loader.timeout = 0;
            };
        })
    ];
}
