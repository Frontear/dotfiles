{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ./boot
    ./network
    ./power-saving
  ];
}
