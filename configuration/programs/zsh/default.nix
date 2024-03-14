{ pkgs, ... }: {
  imports = [
    ./system.nix
  ];

  home-manager.users.frontear = import ./home.nix;
}
