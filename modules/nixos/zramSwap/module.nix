{
  config,
  lib,
  ...
}:
let
  cfg = config.zramSwap;
in {
  config = lib.mkIf cfg.enable {
    # Optimizes swap-related kernel tunings for zram usage
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    # Configures zram to work higher than any other swap devices.
    zramSwap = {
      memoryPercent = 150; # https://unix.stackexchange.com/a/596929
      priority = 100;
    };
  };
}