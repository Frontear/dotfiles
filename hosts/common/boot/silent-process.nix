{ ... }: {
  # Silences logging of console in preboot as well as stage-<1/2> nix scripts
  boot = {
    consoleLogLevel = 0;

    initrd.verbose = false;

    # Prevents kernel messages from being displayed on boot, usually okay
    kernel.sysctl = {
      "kernel.printk" = "0 0 0 0";
    };


    # Tells system to hide messages, and includes a systemd and udev specific rule
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "udev.log_level=0"
    ];

    # Don't let the bootloader hang on selection, just load the latest gen.
    loader.timeout = 0;
  };
}
