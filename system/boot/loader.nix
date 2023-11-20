{ ... }:
{
    # use systemd-boot
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot = {
        enable = true;

        configurationLimit = 5; # TODO: make infinite?
        memtest86.enable = true;
    };
}
