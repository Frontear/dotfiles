{ ... }: {
  # Opens up these ports for the sake of Quiclime testing.
  networking.firewall = {
    allowedTCPPorts = [ 25565 25575 25585 ];
    allowedUDPPorts = [ 25565 25575 25585 ];
  };
}
