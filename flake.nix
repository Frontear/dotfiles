{
    description = "Flake for my systems, imports all the default things";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        impermanence.url = "github:nix-community/impermanence";

        nixos-hardware.url = "github:NixOS/nixos-hardware";
    };

    outputs = { self, nixpkgs, nixos-hardware, ... } @ inputs: {
        nixosConfigurations."frontear-net" = nixpkgs.lib.nixosSystem {
            specialArgs = {
                inherit nixos-hardware;
                hostname = "frontear-net";
                username = "frontear";
            };
            modules = [
                inputs.home-manager.nixosModules.default
                inputs.impermanence.nixosModules.impermanence

                ./hosts/laptop

                {
                    # https://ayats.org/blog/channels-to-flakes
                    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
                    nix.registry = {
                        nixpkgs.flake = nixpkgs;
                    };
                }
            ];
        };
    };
}
