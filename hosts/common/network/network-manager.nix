{ ... }: {
  # Enable and use NetworkManager, my personal preference.
  networking.networkmanager.enable = true;

  # Tags /etc/NetworkManager for impermanence, if its enabled.
  impermanence.root.directories = [
    "/etc/NetworkManager/"
  ];

  # Disable this systemd service since it takes up to 5-10 seconds
  # at boot time for no reason, delaying the boot process.
  systemd.services."NetworkManager-wait-online".enable = false;
}
