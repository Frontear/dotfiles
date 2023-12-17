{
    pkgs,
    ...
}: {
    boot.blacklistedKernelModules = [ "bluetooth" "snd_hda_codec_hdmi" ];
    boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_guc=3 enable_psr=2 fastboot=1
    options iwlmvm power_scheme=3
    options iwlwifi power_level=3 power_save=Y uapsd_disable=0
    options snd_hda_intel power_save=1 power_save_controller=Y
    '';
    boot.kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.dirty_ratio" = 3;
        "vm.dirty_background_ratio" = 1;
        "vm.laptop_mode" = 5;
        "vm.vfs_cache_pressure" = 50;
    };
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;

    environment.systemPackages = with pkgs; [
    #    powerdevil
        powertop
    ];

    networking.networkmanager.wifi.powersave = true;

    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = "powersave";
    powerManagement.cpufreq.max = 3000000;
    powerManagement.scsiLinkPolicy = "med_power_with_dipm";

    # TODO: services.auto-cpufreq
    # TODO: services.irqbalance
    services.thermald.enable = true;
    # TODO: services.throttled
    # TODO: services.tlp
    services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="scsi", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    '';
    # TODO: services.upower

    systemd.tmpfiles.rules = [
        "z /sys/class/backlight/*/brightness 0644 - wheel - -"
        "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"
        "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
        "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"
    ];
}
