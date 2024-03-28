{ ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;

      memtest86.enable = true;
    };

    timeout = 0;
  };
}