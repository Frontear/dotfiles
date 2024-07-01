{
  self,
  nixpkgs,
  home-manager,
  impermanence,
  nix-vscode-extensions,
  nixos-hardware,
  nixos-wsl,
  nixvim,
  ...
}:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.callPackage ./shell.nix { };
  };

  flake = {
    nixosConfigurations = {
      "LAPTOP-3DT4F02" = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.default

          (import ../hosts/common { inherit home-manager; })
          (import ../hosts/laptop { inherit nixos-hardware; })
        ];
      };

      "nixos" = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.default

          (import ../hosts/common { inherit home-manager; })
          (import ../hosts/desktop-wsl { inherit nixos-wsl; })
        ];
      };
    };

    nixosModules.default = import ../modules { inherit impermanence nix-vscode-extensions nixvim; };
  };
}
