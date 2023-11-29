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
            specialArgs = {
                username = "frontear";
                hostname = "frontear-net";
                ags = inputs.ags;
            };
            modules = [
                inputs.home-manager.nixosModules.default
                inputs.impermanence.nixosModules.impermanence
                inputs.nixos-hardware.nixosModules.dell-inspiron-14-5420

                ./configuration.nix
            ];
        };
    };
}
