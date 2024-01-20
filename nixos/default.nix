{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./impermanence.nix
    ./mounts.nix
    ./network.nix
    ./swap.nix
  ];
}
