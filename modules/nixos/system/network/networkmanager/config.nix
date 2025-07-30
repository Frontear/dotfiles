{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.network.networkmanager;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "/etc/NetworkManager"
    ];

    networking = {
      modemmanager.enable = lib.mkForce false;


      networkmanager = {
        enable = true;

        plugins = with pkgs; [
          networkmanager-openvpn
        ];
      };


      dhcpcd.enable = lib.mkForce false;
      networkmanager.dns = lib.mkForce "none";
      useDHCP = lib.mkForce false;

      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];


      stevenblack = {
        enable = true;

        block = [ "fakenews" "gambling" "porn" ];
      };
    };
  };
}
