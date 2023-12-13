{ inputs, nixpkgs, ... }: {
    "laptop" = nixpkgs.lib.nixosSystem {
        specialArgs = {
            inherit inputs nixpkgs;
        };
        modules = [
            ./laptop
            ../modules
        ];
    };
}
