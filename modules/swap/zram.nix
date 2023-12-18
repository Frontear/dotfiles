{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkIf;
in {
    config = mkIf config.zramSwap.enable {
        # https://wiki.archlinux.org/title/Zram
        boot.kernel.sysctl = {
            "vm.swappiness" = 180;
            "vm.watermark_boost_factor" = 0;
            "vm.watermark_scale_factor" = 125;
            "vm.page-cluster" = 0;
        };

        zramSwap.priority = 100;
    };
}
