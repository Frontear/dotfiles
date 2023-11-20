{ ... }:
{
    imports = [
        ./dns.nix
        ./power_saving.nix
        ./stevenblack.nix
    ];

    # use network manager for networking
    networking.networkmanager.enable = true;

    # TODO: move?
    # enable wireless regulatory database
    hardware.wirelessRegulatoryDatabase = true;
}
