{ ... }: let
    _hostname = "frontear-net";
in {
    _module.args = {
        username = "frontear";
        hostname = "${_hostname}";
    };

    imports = [
        ./boot.nix
        ./swap.nix
        ./user.nix

        ./modules
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    networking.hostName = "${_hostname}";
    time.timeZone = "America/Toronto";
}
