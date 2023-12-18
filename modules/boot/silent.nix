{
    config,
    lib,
    ...
}:
let
    inherit (lib) mdDoc mkIf mkOption types;
in {
    options.boot.silent = mkOption {
        type = types.bool;
        description = mdDoc ''
        Completely silences all boot output from
        both the kernel and NixOS scripts.
        '';
    };

    config = mkIf config.boot.silent {
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
    };
}
