{
  config,
  lib,
  ...
}:
let
  cfg = config.my.mounts.swap;
in {
  options.my.mounts.swap = {
    enableZram = lib.mkDefaultEnableOption "swap.enableZram";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableZram {
      # Optimizes swap-related kernel tunings for zram usage
      # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
      boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
      };

      # Enables and configures zram to work higher than any other swap devices.
      zramSwap = {
        enable = true;
        memoryPercent = 150; # https://unix.stackexchange.com/a/596929
        priority = 100;
      };
    })
  ];
}