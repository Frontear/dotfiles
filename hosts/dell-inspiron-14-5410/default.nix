{
  imports = [
    ./configuration.nix
  ];

  config = {
    hardware.facter.reportPath = ./facter.json;

    system.stateVersion = "25.05";
  };
}