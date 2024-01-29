{ ... }: {
  # Tweaks to improve performance of zram when used as swap.
  # From: https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # Enabling zram to use as a swap device.
  # TODO: add writebackDevice to write non-compressible pages elsewhere
  zramSwap = {
    enable = true;
    priority = 100;
  };
}
