{ pkgs, ... }:
{
    # network
    networking.dhcpcd.enable = false; # network manager uses internal
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
    networking.firewall.enable = true;

    # pipewire
    sound.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        jack.enable = true;
        pulse.enable = true;

        wireplumber.enable = true;
    };

    # printing
    services.printing = {
        enable = true;
        cups-pdf.enable = true;
        drivers = with pkgs; [
            samsung-unified-linux-driver
        ];
    };
}
