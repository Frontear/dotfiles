{ ... }:
{
    #boot.extraModprobeConfig =
    #''
    #options iwlwifi uapsd_disable=0 power_save=1 power_level=3
    #options iwlmvm power_scheme=3
    #'';

    networking.networkmanager.wifi.powersave = true;
}
