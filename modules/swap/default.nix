{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf mkMerge;
in {
    config = mkMerge [
        (mkIf config.zramSwap.enable {
            # https://wiki.archlinux.org/title/Zram
            boot.kernel.sysctl = {
                "vm.swappiness" = 180;
                "vm.watermark_boost_factor" = 0;
                "vm.watermark_scale_factor" = 125;
                "vm.page-cluster" = 0;
            };

            # Force to use over any other swap devices
            zramSwap.priority = 100;
        })
    ];
}
