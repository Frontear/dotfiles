{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./audio
    ./boot
    ./mounts
    ./network
    ./nix
  ];
}