{
  ...
}:
{
  config = {
    # Use tmpfs for /tmp. Normally this would be an issue due to
    # Nix builders, but we've overwritten the location Nix writes
    # to. Additionally, cleaning on boot takes too long, hence why
    # it's better to just let it stay a tmpfs.
    boot.tmp.useTmpfs = true;
  };
}
