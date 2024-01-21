{
  nixpkgs,
  inputs
}: {
  "LAPTOP-3DT4F02" = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

    modules = [
      ./common
      ./laptop
    ];
  };
}
