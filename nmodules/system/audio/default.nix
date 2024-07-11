{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./pipewire.nix
  ];
}