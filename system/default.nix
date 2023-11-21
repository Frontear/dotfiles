{ hostname, ... }:
{
    imports = [
        ./desktop
        ./users
    ];

    # sets system locale
    i18n.defaultLocale = "en_US.UTF-8";

    # sets system hostname
    networking.hostName = "${hostname}";

    # sets timezone
    time.timeZone = "America/Toronto";
}
