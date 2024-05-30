{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.zram;
in {
  options.frontear.zram = {
    enable = mkEnableOption "opinionated zram module.";
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    zramSwap = {
      enable = true;

      algorithm = "zstd";
      memoryPercent = 150; # https://unix.stackexchange.com/a/596929
      priority = 100;
      # TODO: writebackDevice
    };
  };
}