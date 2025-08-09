{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.networkmanager;
in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Enable NetworkManager and persist it's directory to preserve
      # connection information across reboots.
      my.persist.directories = [
        "/etc/NetworkManager"
      ];

      networking.networkmanager.enable = true;
    }
    {
      # Grab some NetworkManager plugins to use.
      networking.networkmanager.plugins = with pkgs; [
        networkmanager-openvpn
      ];
    }
    {
      # Disable ModemManager, as I don't have any use for it.
      networking.modemmanager.enable = lib.mkForce false;
    }
    {
      # Disable automatic DNS resolution when connecting to a network,
      # forcing our own DNS servers.
      #
      # WARN: this is a dangerous operation that can break networks
      # that rely on a private DNS server to access secured resources.
      #
      # TODO: re-structure this to avoid the dangerous pitfall mentioned.
      # see: https://wiki.archlinux.org/title/NetworkManager#Custom_DNS_servers
      networking = {
        dhcpcd.enable = lib.mkForce false;
        networkmanager.dns = lib.mkForce "none";
        useDHCP = lib.mkForce false;

        nameservers = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
    }
    {
      # Use a custom `/etc/hosts` list from StevenBlack.
      networking.stevenblack = {
        enable = true;

        block = [ "fakenews" "gambling" "porn" ];
      };
    }
  ]);
}
