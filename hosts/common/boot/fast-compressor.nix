{ ... }: {
  # Uses lz4, a lighter compressor for kernel images to make bootup faster.
  # This has the consequence of requiring more diskspace, but I'd rather
  # save some time in boot then save megabytes on my massive disk.
  boot.initrd = {
    compressor = "lz4";
    compressorArgs = [
      "-l"
      "-9"
    ];
  };
}
