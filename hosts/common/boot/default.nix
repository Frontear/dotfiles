{ ... }: {
  # Don't bother compressing images.
  boot.initrd.compressor = "cat";

  # Relegate bootup to systemd in stage 2
  boot.initrd.systemd.enable = true;

  # Silences all boot output to ensure a clean framebuffer until getty login
  # From: https://wiki.archlinux.org/title/Silent_boot
  boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=3" ];
  boot.consoleLogLevel = 3;
  boot.loader.timeout = 0;
  boot.kernel.sysctl = {
    "kernel.printk" = "3 3 3 3";
  };
}
