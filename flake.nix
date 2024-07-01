{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      ./nix
    ];
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    flake = {
      nixosConfigurations = {
        "LAPTOP-3DT4F02" = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default

            (import ./hosts/common { inherit (inputs) home-manager; })
            (import ./hosts/laptop { inherit (inputs) nixos-hardware; })
          ];
        };

        "nixos" = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default

            (import ./hosts/common { inherit (inputs) home-manager; })
            (import ./hosts/desktop-wsl { inherit (inputs) nixos-wsl; })
          ];
        };
      };

      nixosModules.default = import ./modules { inherit (inputs) impermanence nixvim nix-vscode-extensions; };
    };
  };
}
