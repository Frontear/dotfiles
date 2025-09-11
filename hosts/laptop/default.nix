{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  config = {
    system.stateVersion = "25.05";
  };
}