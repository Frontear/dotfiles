{ ... }: {
  # Enables systemd at stage 2 instead of using NixOS scripts.
  # This has an added benefit of silencing log output.
  boot.initrd.systemd.enable = true;
}
