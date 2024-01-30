{ ... }: {
  # Open up some ports for Quiclime.
  # TODO: is this possible to do from a devshell?
  networking.firewall =
  let
    ports = [ 25565 25575 25585 ];
  in {
    allowedTCPPorts = [] ++ ports;
    allowedUDPPorts = [] ++ ports;
  };
}
