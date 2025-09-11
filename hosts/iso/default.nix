{
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  config = {
    isoImage = {
      edition = "frontear";
      squashfsCompression = "lz4";
    };
  };
}