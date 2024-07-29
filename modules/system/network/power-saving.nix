{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.network;
in {
  config = mkIf (cfg.enable && config.powerManagement.enable) {
    # WARN: impure!!
    boot.extraModprobeConfig = ''
      options iwlwifi power_level=3 power_save=1 uapsd_disable=0
      options iwlmvm power_scheme=3
    '';

    networking.networkmanager.wifi.powersave = true;
  };
}