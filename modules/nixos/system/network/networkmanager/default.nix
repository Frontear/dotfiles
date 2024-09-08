{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce mkIf mkMerge;
in {
  options.my.system.network.networkmanager.enable = mkEnableOption "swap";

  config = mkIf config.my.system.network.networkmanager.enable (mkMerge [
    {
      # Enable networkmanager and persist it in case of impermanence.
      networking.networkmanager.enable = true;
      my.persist.directories = [ "/etc/NetworkManager" ];
    }
    {
      # Disable networkmanager and nixos dns capabilities
      networking.networkmanager.dns = mkForce "none";

      networking.useDHCP = mkForce false;
      networking.dhcpcd.enable = mkForce false;

      # Use cloudflare's dns servers
      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    }
    {
      # Use stevenblack/hosts as a hosts list
      networking.stevenblack.enable = true;
      networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];
    }
    {
      # Setup some explicit power-savings for network cards and networkmanager.
      # WARN: modprobe config is impure!
      boot.extraModprobeConfig = ''
        options iwlwifi power_level=3 power_save=1 uapsd_disable=0
        options iwlmvm power_scheme=3
      '';

      networking.networkmanager.wifi.powersave = true;
    }
  ]);
}