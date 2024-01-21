{ ... }: {
  # Enable flake support, this is mostly for new systems that will be configured on install,
  # since they will no longer have flake capabilities if this option isn't set ahead of time.
  nix.settings.experimental-features = "nix-command flakes";
}
