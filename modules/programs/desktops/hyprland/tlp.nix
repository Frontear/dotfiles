{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.desktops.hyprland;
in {
  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;

      settings = {
        TLP_DEFAULT_MODE = "BAT";
        TLP_PERSISTENT_DEFAULT = 1;

        SOUND_POWER_SAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_CONTROLLER = "Y";

        START_CHARGE_THRESH_BAT0 = 10;
        STOP_CHARGE_THRESH_BAT0 = 80;
        # RESTORE_THRESHOLDS_ON_BAT = 1;
        NATACPI_ENABLE = 1;

        DISK_DEVICES = "nvme0n1"; # TODO: find from fileSystems?
        DISK_APM_LEVEL_ON_BAT = "128";
        DISK_APM_CLASS_DENYLIST = "usb";
        DISK_IOSCHED = "mq-deadline";
        SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
        AHCI_RUNTIME_PM_ON_BAT = "auto";
        AHCI_RUNTIME_PM_TIMEOUT = 10;

        DISK_IDLE_SECS_ON_BAT = 2;
        MAX_LOST_WORK_SECS_ON_BAT = 60;

        INTEL_GPU_MIN_FREQ_ON_BAT = 100;
        INTEL_GPU_MAX_FREQ_ON_BAT = 700;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 1400;

        NMI_WATCHDOG = 0;

        WIFI_PWR_ON_BAT = "on";
        WOL_DISABLE = "Y";

        PLATFORM_PROFILE_ON_BAT = "low-power";
        MEM_SLEEP_ON_BAT = "s2idle";

        CPU_DRIVER_OPMODE_ON_BAT = "active";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        #CPU_MIN_PERF_ON_BAT = 8;
        CPU_MAX_PERF_ON_BAT = 100;
        CPU_BOOST_ON_BAT = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 1;

        RESTORE_DEVICE_STATE_ON_STARTUP = 0;
        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";

        RUNTIME_PM_ON_BAT = "auto";
        PCIE_ASPM_ON_BAT = "powersupersave";

        USB_AUTOSUSPEND = 1;
        USB_EXCLUDE_PHONE = 1;
      };
    };
  };
}