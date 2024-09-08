{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options.my.mounts.swap.enable = mkEnableOption "swap";

  config = mkIf config.my.mounts.swap.enable {
    # Optimizes swap-related kernel tunings for zram usage
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    # Enables and configures zram to work higher than any other swap devices.
    zramSwap.enable = true;
    zramSwap.algorithm = "zstd";
    zramSwap.memoryPercent = 150; # https://unix.stackexchange.com/a/596929
    zramSwap.priority = 100;
    # TODO: writebackDevice?
  };
}