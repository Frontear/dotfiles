# Highly system-specific tweaks with a dash of opinionated tweaks
# designed to pull as much battery life out of my laptop, even at
# the cost of worse performance.
#
# TODO: improve ordering, maybe separate, and ffs explain better.
{ ... }: {
  boot = {
    # Disable bluetooth here because I hardly make use of it on my laptop.
    # Disable HDMI audio module because
    #   a) I never have anything in the HDMI port anyways
    #   b) I almost never use the audio on my laptop, funny enough.
    blacklistedKernelModules = [
      "bluetooth"
      "snd_hda_codec_hdmi"
    ];

    # Setup some extra powersaving oriented kernel module settings.
    # Pretty much all of these were scrapped together from the
    # Arch wiki. I'm not too certain of the compatibility,
    # but it is something I need to take a look at some time.
    #
    # TODO: check the compatibility of these.
    # TODO: add explanations of all the options.
    extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_psr=2 fastboot=1 enable_guc=3

    options iwlwifi uapsd_disable=0 power_save=1 power_level=3
    options iwlmvm power_scheme=3

    options snd_hda_intel power_save=1 power_save_controller=1
    '';

    # Some various sysctl options that can help improve power
    # and lifetime of the battery.
    #
    # TODO: add explanations of all the options.
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;

      "vm.dirty_writeback_centisecs" = 6000;

      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 1;

      "vm.laptop_mode" = 5;

      "vm.vfs_cache_pressure" = 50;
    };
  };


  # tmpfiles that help set some performance values directly
  # through sysfs.
  #
  # TODO: add explanations of all the options.
  systemd.tmpfiles.rules = [
    # TODO: move this from here to elsewhere, this is NOT a power-saving thing.
    "z /sys/class/backlight/*/brightness 0664 - wheel - -"

    "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"

    #"w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"

    "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"

    "w /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq - - - - 3000000"
  ];

  # A rash power-saving attempt on all peripherals
  # within the system. This may have larger
  # implications on the system, but I
  # wouldn't know.
  #
  # TODO: add explanations of all the options.
  services.udev.extraRules = ''
  SUBSYSTEM=="pci", ATTR{power/control}="auto"
  SUBSYSTEM=="scsi", ATTR{power/control}="auto"
  '';#ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"

  # I've enabled powerManagement because I _think_ there are
  # other modules that enable personalized power saving
  # functionality. I'm not actually sure of this.
  #
  # TODO: add explanations of all the options.
  powerManagement.enable = true;
  services = {
    power-profiles-daemon.enable = true; # TODO: impermanence link
    thermald.enable = true;
    #tlp.enable = true;
  };

  # Persist the state.ini file from power-profiles.
  impermanence.root.files = [
    "/var/lib/power-profiles-daemon/state.ini"
  ];
}
