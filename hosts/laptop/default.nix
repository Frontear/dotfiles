{ nixpkgs, home-manager, impermanence, nixos-hardware, ... }:
{
    imports = [
        home-manager.nixosModules.default
        impermanence.nixosModules.impermanence
        nixos-hardware.nixosModules.dell-inspiron-14-5420

        ./hardware-configuration.nix
        ./configuration.nix
    ];

    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nix.registry = {
        nixpkgs.flake = nixpkgs;
    };
}
