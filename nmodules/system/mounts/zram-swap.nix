{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.mounts;
in {
  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    zramSwap.algorithm = "zstd";
    zramSwap.memoryPercent = 150; # https://unix.stackexchange.com/a/596929
    zramSwap.priority = 100;
    # TODO: writebackDevice?
  };
}