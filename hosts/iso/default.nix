{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  config = {
    isoImage = {
      isoBaseName = "frontear-nixos";
      squashfsCompression = "lz4";
    };
  };
}
