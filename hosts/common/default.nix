{ hostname, ... }:
{
    imports = [
        ./boot.nix
        ./swap.nix
        ./user.nix

        ./modules
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    networking.hostName = "${hostname}";
    time.timeZone = "America/Toronto";
}
