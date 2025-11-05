{
  imports = [
    ./configuration.nix
    #./hardware-configuration.nix
  ];

  config = {
    facter.reportPath = ./facter.json;

    system.stateVersion = "25.05";
  };
}