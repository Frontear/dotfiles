{ config, lib, hostname, ... }: {
    networking.dhcpcd.enable = false;
    networking.firewall.enable = true;
    networking.hostName = "${hostname}";
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];
    networking.networkmanager.enable = true;
    networking.networkmanager.dhcp = "internal";
    networking.networkmanager.dns = "none";
    networking.networkmanager.wifi = lib.mkIf config.powerManagement.enable {
        powersave = true;
    };
    networking.stevenblack.enable = true;
    networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];

    systemd.services."NetworkManager-wait-online".enable = false;
}
