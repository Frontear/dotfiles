{ ... }:
{
    # enable power management
    powerManagement.enable = true;

    # forces the powersaving governer
    powerManagement.cpuFreqGovernor = "powersave";

    # sets cpu freq TODO: move to hardware-configuration
    powerManagement.cpufreq.max = 3000000;
}
