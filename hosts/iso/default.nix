{
  lib,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  config = {
    isoImage = {
      isoBaseName = lib.mkForce "frontear-nixos";
      squashfsCompression = "lz4";
    };
  };
}
