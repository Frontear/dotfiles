{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./zram-swap.nix
  ];
}