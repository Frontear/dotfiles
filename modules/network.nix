{ config, lib, hostname, ... }: {
    networking = {
        dhcpcd.enable = false; # NetworkManager has its own resolver
        firewall.enable = true;
        hostName = "${hostname}";
        nameservers = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
        ];
        networkmanager = {
            enable = true;
            dhcp = "internal";
            dns = "none"; # forces the use of our defined nameservers
            wifi.powersave = config.powerManagement.enable;
        };
        stevenblack = {
            enable = true;
            block = [ "fakenews" "gambling" "porn" ];
        };
    };

    systemd.services."NetworkManager-wait-online".enable = false; # eats up 3+ seconds at boot time
}
