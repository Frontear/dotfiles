{ ... }: {
  # Enable and use NetworkManager, my personal preference.
  # TODO: move the impermanence declaration here?
  networking.networkmanager.enable = true;

  # Disable this systemd service since it takes up to 5-10 seconds
  # at boot time for no reason, delaying the boot process.
  systemd.services."NetworkManager-wait-online".enable = false;
}
