{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./options.nix
    (import ./config.nix {
      inherit
        inputs
        config
        lib
        pkgs
        ;
    })
  ];
}
