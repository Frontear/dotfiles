{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { self, ... }:
  let
    inherit (self) inputs;
  in {
    nixosConfigurations."LAPTOP-3DT4F02" = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.impermanence.nixosModules.impermanence

        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
