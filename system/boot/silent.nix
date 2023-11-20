{ ... }:
{
    # suppress majority log info
    boot.consoleLogLevel = 3;

    # hides majority of boot text (besides the nix boot scripts unfortunately)
    boot.initrd.verbose = false;

    # https://wiki.archlinux.org/title/Silent_boot
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "rd.udev.log_level=3" ];
    boot.kernel.sysctl = {
        "kernel.printk" = "3 3 3 3";
    };

    # don't show systemd boot screen (can see if spacebar held while booting)
    boot.loader.timeout = 0;

    # nixos scripts still populate boot screen, so we use plymouth to hide it all
    # TODO: above needed?
    boot.plymouth.enable = true;
}
