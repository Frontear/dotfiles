{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.networking.networkmanager;

  blocklist = pkgs.concatText "blocklist" [
    "${pkgs.stevenblack-blocklist}/alternates/fakenews-gambling-porn/hosts"
  ];
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
      # OpenVPN plugin for the school VPN service.
      plugins = with pkgs; [
        networkmanager-openvpn
      ];

      # Having power-saving enabled causes some weird instability with the
      # connection, so it's just safer to default it to off.
      wifi.powersave = lib.mkDefault false;
    };

    # Use `dnsmasq` as our local DNS resolver to accomplish two things.
    # Firstly, it will use the Cloudflare DNS servers to route DNS requests,
    # and secondly, it will block connections in StevenBlack/hosts without
    # needing to add them to `/etc/hosts`.
    services.dnsmasq = {
      enable = true;

      settings = {
        # Force `dnsmasq` to act locally only.
        bind-interfaces = true;
        listen-address = [
          "127.0.0.1"
          "::1"
        ];

        # Force `dnsmasq` to preferentially use Cloudflare's DNS servers first.
        strict-order = true;
        server = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];

        # Blocklist of known bad connections.
        addn-hosts = "${blocklist}";

        cache-size = 10000; # default of 150 is too small
      };
    };
  };
}