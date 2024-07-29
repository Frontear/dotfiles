{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.network;
in {
  config = mkIf cfg.enable {
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