{ nixpkgs, home-manager, impermanence, ... }:
{
    imports = [
        home-manager.nixosModules.default
        impermanence.nixosModules.impermanence

        ./hardware-configuration.nix
        ./configuration.nix
    ];

    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nix.registry = {
        nixpkgs.flake = nixpkgs;
    };
}
