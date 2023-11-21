{ ... }:
{
    # network
    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "none";
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];
    networking.stevenblack = {
        enable = true;
        block = [ "fakenews" "gambling" "porn" "social" ];
    };
}
