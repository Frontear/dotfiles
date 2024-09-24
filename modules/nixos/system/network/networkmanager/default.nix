{
  config,
  lib,
  ...
}:
let
  cfg = config.my.network.networkmanager;
in {
  options.my.network.networkmanager = {
    enable = lib.mkEnableOption "networkmanager";

    enablePowerSave = lib.mkEnableOption "networkmanager.enablePowerSave";

    dns = {
      providers = {
        cloudflare = {
          enable = lib.mkEnableOption "networkmanager.dns.providers.cloudflare" // { default = true; };
        };
      };

      servers = lib.mkOption {
        default = [];

        type = with lib.types; listOf str;
      };
    };

    hosts = {
      providers = {
        stevenblack = {
          enable = lib.mkEnableOption "networkmanager.hosts.stevenblack" // { default = true; };
          block = lib.mkOption {
            default = [ "fakenews" "gambling" "porn" ];

            type = with lib.types; listOf str;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Enable NetworkManager and persist it's important directories
      my.persist.directories = [ "/etc/NetworkManager" ];
      networking.networkmanager.enable = true;

      # Enable powersaving if demanded
      networking.networkmanager.wifi.powersave = cfg.enablePowerSave;

      # Get stevenblack hosts
      networking.stevenblack = cfg.hosts.providers.stevenblack;
    }
    (lib.mkIf (cfg.dns.servers != []) {
      # Kill all DNS resolution features, use ours only
      networking.networkmanager.dns = lib.mkForce "none";

      networking.useDHCP = lib.mkForce false;
      networking.dhcpcd.enable = lib.mkForce false;

      networking.nameservers = cfg.dns.servers;
    })
    (lib.mkIf cfg.dns.providers.cloudflare.enable {
      my.network.networkmanager.dns.servers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    })
  ]);
}
