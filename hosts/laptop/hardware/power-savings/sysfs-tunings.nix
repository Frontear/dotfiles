{
  ...
}:
{
  config = {
    # Set the Intel EPB (performance and energy bias hint)
    # to 8. This is higher than the default of 6, which
    # corresponds to "normal, default".
    #
    # https://wiki.archlinux.org/title/CPU_frequency_scaling#Intel_performance_and_energy_bias_hint
    # man 8 x86_energy_perf_policy
    systemd.tmpfiles.rules = [
      "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"
    ];

    # Set the SATA Active Link Power Management.
    # The absolute lowest is 'min_power' but it comes with a very huge
    # likelehood of data loss. The next safest is 'med_power_with_dipm',
    # and whilst it has become a default on some systems, there's no
    # problem with forcing it.
    #
    # https://wiki.archlinux.org/title/Power_management#SATA_Active_Link_Power_Management
    powerManagement.enable = true;
    powerManagement.scsiLinkPolicy = "med_power_with_dipm";
  };
}
