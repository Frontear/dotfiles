{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf (config.networking.networkmanager.enable && config.powerManagement.enable) {
    # WARN: impure!!
    boot.extraModprobeConfig = ''
      options iwlwifi power_level=3 power_save=1 uapsd_disable=0
      options iwlmvm power_scheme=3
    '';

    networking.networkmanager.wifi.powersave = true;
  };
}