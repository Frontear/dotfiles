{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./boot-loader.nix
    ./silent-boot.nix
  ];
}