{ ... }:
{
    imports = [
        ./boot
        ./desktop
        ./hardware
        ./network
        ./programs
        ./users
        ./zram
    ];

    # sets system locale
    i18n.defaultLocale = "en_US.UTF-8";

    # sets system hostname
    networking.hostName = "frontear-net";

    # sets timezone
    time.timeZone = "America/Toronto";
}
