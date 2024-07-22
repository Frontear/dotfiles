{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    home-manager
    nixos-hardware
    nixos-wsl
    nixpkgs
    ;

  extLib = nixpkgs.lib.extend (final: prev: import ../lib prev);
in {
  perSystem = { pkgs, ... }: {
    devShells.default = import ./shell.nix { inherit pkgs; };
  };

  flake = {
    nixosConfigurations = {
      "LAPTOP-3DT4F02" = extLib.nixosSystem {
        modules = [
          self.nixosModules.default
          self.nixosModules.new

          (import ../hosts/common { inherit home-manager; })
          (import ../hosts/laptop { inherit nixos-hardware; })
        ];
      };

      "nixos" = extLib.nixosSystem {
        modules = [
          self.nixosModules.default
          self.nixosModules.new

          (import ../hosts/common { inherit home-manager; })
          (import ../hosts/desktop-wsl { inherit nixos-wsl; })
        ];
      };
    };

    nixosModules.default = import ../modules { };

    nixosModules.new = import ../nmodules inputs;
  };
}
