{
  ...
}:
{
  config = {
    boot.blacklistedKernelModules = [
      "btusb"
      "bluetooth"
      "snd_hda_codec_hdmi"
    ];

    boot.kernelParams = [
      "pcie_aspm.policy=powersupersave"
    ];

    powerManagement.enable = true;
    powerManagement.scsiLinkPolicy = "med_power_with_dipm";

    # TODO: /sys/devices/system/cpu/cpu*/power/energy_perf_bias -> 8/15

    boot.kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
    };

    services.tlp.enable = false;

    services = {
      auto-cpufreq.enable = true;
      thermald.enable = true;
    };
  };
}
