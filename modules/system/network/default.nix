{ ... }: ({ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.system.network;
in {
  options.frontear.system.network = {
    enable = mkEnableOption "opinionated network module.";
  };

  config = mkIf cfg.enable {
    impermanence.system.directories = [ "/etc/NetworkManager" ];

    networking = {
      networkmanager.enable = true;

      networkmanager.dns = "none";
      stevenblack.enable = true;
      stevenblack.block = [ "fakenews" "gambling" "porn" ];

      useDHCP = false;
      dhcpcd.enable = false;
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    boot.extraModprobeConfig = ''
    options iwlwifi power_level=3 power_save=1 uapsd_disable=0
    options iwlmvm power_scheme=3
    '';
    networking.networkmanager.wifi.powersave = true;
  };
})