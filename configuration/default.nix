{ inputs }: {
  "LAPTOP-3DT4F02" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.impermanence.nixosModules.impermanence
      inputs.home-manager.nixosModules.home-manager

      ./hardware-configuration.nix
      ./configuration.nix
    ];
  };
}
