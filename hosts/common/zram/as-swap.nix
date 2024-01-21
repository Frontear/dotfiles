{ ... }: {
  # Enables the usage of zram block device for swap purposes.
  # TODO: add writebackDevice to save on zram space.
  zramSwap = {
    enable = true;
    priority = 100;
  };
}
