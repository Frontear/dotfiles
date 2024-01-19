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

  # Snippet from Misterio77/nix-starter-configs
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
}
