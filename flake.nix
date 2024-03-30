{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-staging.url = "github:NixOS/nixpkgs/50812f5204a09e54cf305890ba4e1a0ff53ee879";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stevenblack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
  };

  outputs = { self, ... }:
  let
    inherit (self) inputs;
  in {
    nixosConfigurations."LAPTOP-3DT4F02" = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./nixos/configuration.nix
      ];
    };
  };
}
