{ ... }:
{
    # set some sysctl values to improve the usage of zram
    boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
    };

    # enable zramswap with a high priority
    zramSwap = {
        enable = true;
        priority = 100;
    };
}
