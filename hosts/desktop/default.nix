{ nixpkgs, home-manager, impermanence, nixos-hardware, ... }:
{
    imports = [
        home-manager.nixosModules.default
        impermanence.nixosModules.impermanence

        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd

        ./hardware-configuration.nix
        ../common/configuration.nix
        ./configuration.nix
    ];

    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nix.registry = {
        nixpkgs.flake = nixpkgs;
    };
}
