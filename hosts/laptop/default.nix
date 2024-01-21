{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ./firewall-ports.nix

    ./boot
    ./power-saving
  ];
}
