{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.networking.networkmanager;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        # TODO: better to persist `system-connections` directory only?
        path = "/etc/NetworkManager";
        unique = false;
      }
      {
        # Due to NixOS hardening the `wpa_supplicant` daemon by default,
        # the daemon can no longer arbitrarily read files on the filesystem.
        #
        # This has affected my certificates, which are imperatively stored and
        # configured on a network-basis. To counter this, NixOS exposes the
        # `/etc/wpa_supplicant` directory, which is where certificates should
        # go, with the daemon being configured to read this directory.
        #
        # Files placed in the aforementioned directory must also be owned by
        # the `wpa_supplicant` user and group of the same name.
        #
        # see: https://github.com/NixOS/nixpkgs/pull/427528
        path = "/etc/wpa_supplicant";
        unique = false;
      }
    ];

    # Enables broadband support, but I don't need this.
    networking.modemmanager.enable = lib.mkForce false;

    networking.networkmanager = {
      # Throw the Cloudflare DNS servers _before_ any DHCP ones. This will
      # preferentially use Cloudflare for any DNS queries, and any queries
      # that cannot be resolved through Cloudflare will simply try the next
      # best DNS servers.
      insertNameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];

      # OpenVPN plugin for the school VPN service.
      plugins = with pkgs; [
        networkmanager-openvpn
      ];

      # Having power-saving enabled causes some weird instability with the
      # connection, so it's just safer to default it to off.
      wifi.powersave = lib.mkDefault false;
    };

    # Amazing curated list of hosts to throw into `/etc/hosts`.
    #
    # see: https://github.com/StevenBlack/hosts
    networking.stevenblack = {
      enable = true;

      block = [ "fakenews" "gambling" "porn" ];
    };
  };
}