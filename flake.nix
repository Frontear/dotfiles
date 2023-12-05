{
    description = ""; # TODO

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        impermanence.url = "github:nix-community/impermanence";

        nixos-hardware.url = "github:NixOS/nixos-hardware";
    };

    outputs = { self, nixpkgs, ... } @ inputs: {
        nixosConfigurations."frontear-net" = nixpkgs.lib.nixosSystem {
            specialArgs = inputs // {
                hostname = "frontear-net";
                username = "frontear";
            };
            modules = [
                ./hosts/laptop
            ];
        };
    };
}
