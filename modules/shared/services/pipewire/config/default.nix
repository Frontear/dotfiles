{
  imports = [
    ./nixos.nix
  ];

  config.home-manager.sharedModules = [
    ./home-manager.nix
  ];
}