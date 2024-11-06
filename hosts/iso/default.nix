{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  config = {
    isoImage = {
      edition = "frontear-iso";
      squashfsCompression = "lz4";
    };
  };
}
