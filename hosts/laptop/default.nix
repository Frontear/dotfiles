{ nixpkgs, home-manager, impermanence, nixos-hardware, ... }:
{
    imports = [
        home-manager.nixosModules.default
        impermanence.nixosModules.impermanence
        
        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-gpu-intel
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ./hardware-configuration.nix
        ../common/configuration.nix
        ./configuration.nix
    ];

    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nix.registry = {
        nixpkgs.flake = nixpkgs;
    };
}
