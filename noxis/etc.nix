{
  inputs,
  ...
}: {
  boot.blacklistedKernelModules = [
    "bluetooth"
    "snd_hda_codec_hdmi"
  ];

  boot.extraModprobeConfig = ''
  options i915 enable_fbc=1 enable_psr=2 fastboot=1 enable_guc=3

  options iwlwifi uapsd_disable=0 power_save=1 power_level=3
  options iwlmvm power_scheme=3

  options snd_hda_intel power_save=1 power_save_controller=1
  '';

  #security.polkit.extraConfig = ''
  #polkit.addRule(function(action, subject) {
  #  if (subject.isInGroup("wheel")) {
  #    return polkit.Result.YES;
  #  }
  #});
  #'';

  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;

    "vm.dirty_writeback_centisecs" = 6000;

    "vm.dirty_ratio" = 3;
    "vm.dirty_background_ratio" = 1;

    "vm.laptop_mode" = 5;

    "vm.vfs_cache_pressure" = 50;
  };

  systemd.tmpfiles.rules = [
    "z /sys/class/backlight/*/brightness 0664 - wheel - -"

    "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"

    #"w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"

    "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"

    "w /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq - - - - 3000000"
  ];

  services.udev.extraRules = ''
  SUBSYSTEM=="pci", ATTR{power/control}="auto"
  SUBSYSTEM=="scsi", ATTR{power/control}="auto"
  ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';
}
