{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.networking.networkmanager.enable {
    networking.networkmanager.dns = "none";

    networking.useDHCP = false;
    networking.dhcpcd.enable = false;

    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
}