{
  inputs,
  ...
}: {
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [ 25565 25575 25585 ];
      allowedUDPPorts = [ 25565 25575 25585 ];
    };
  };
}
