{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ./power-saving
  ];
}
