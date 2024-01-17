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

    hostFiles = [ "${inputs.stevenblack.outPath}/hosts" ];

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    networkmanager = {
      enable = true;

      dns = "none";
    };
  };

  systemd.services."NetworkManager-wait-online".enable = false;
}
