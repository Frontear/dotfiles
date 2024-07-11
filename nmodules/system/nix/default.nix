{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./channel-compat.nix
    ./nix-settings.nix
    ./nixpkgs-config.nix
  ];
}
