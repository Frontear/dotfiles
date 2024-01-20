{
  config,
  inputs,
  lib,
  ...
}: {
  # Enable unfree packages so I can use things like Microsoft Edge, VSCode, and other packages.
  nixpkgs.config.allowUnfree = true;

  # Enable flake support, this is mostly for new systems that will be configured on install,
  # since they will no longer have flake capabilities if this option isn't set ahead of time.
  nix.settings.experimental-features = "nix-command flakes";

  # Snippets below stolen from Misterio77/nix-starter-configs
  # --------------------------------------------------------
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
  # --------------------------------------------------------
}
