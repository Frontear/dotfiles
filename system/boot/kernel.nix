{ pkgs, ... }:
{
    # lz4 compression is faster decompression = faster boot times
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];

    # use liquorix kernel
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
}
