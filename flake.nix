{
    description = "A very basic flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence = {
            url = "github:nix-community/impermanence";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-hardware = {
            url = "github:NixOS/nixos-hardware";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, ... }@inputs: {
        nixosConfigurations."frontear-net" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = inputs // {
                username = "frontear";
                hostname = "frontear-net";
            };
            modules = [
                ./configuration.nix
            ];
        };
    };
}
