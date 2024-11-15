{
  lib,
  ...
}:
{
  config = {
    # Kill the bluetooth kernel modules, as well
    # as the HDMI audio module.
    boot.blacklistedKernelModules = [
      "btusb"
      "bluetooth"
      "snd_hda_codec_hdmi"
    ];

    # Set the Intel network card to some power saving states.
    # This is adapter specific and the 2nd module entry changes.
    #
    # https://wiki.archlinux.org/title/Power_management#Intel_wireless_cards_(iwlwifi)
    boot.extraModprobeConfig = ''
      options iwlwifi power_level=3 power_save=1 uapsd_disable=0
      options iwlmvm power_scheme=3
    '';

    # Set the PCIe Active State Power Management
    # to powersupersave.
    #
    # Check `journalctl -b | grep "ASPM"` to check if supported
    boot.kernelParams = [
      "pcie_aspm.policy=powersupersave"
    ];

    # Disable the Kernel watchdog. In order to prevent
    # a dangerous lockout condition, enable SysRq here.
    boot.kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "kernel.sysrq" = lib.mkDefault 1;
    };
  };
}
