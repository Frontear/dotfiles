{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        impermanence = {
            url = "github:nix-community/impermanence";
        };

        nix-index-database = {
            url = "github:Mic92/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixos-hardware = {
            url = "github:NixOS/nixos-hardware";
        };
    };

    outputs = {
        self,
        nixpkgs,
        ...
    } @ inputs: {
        nixosConfigurations = import ./hosts { inherit inputs nixpkgs; };
    };
}
