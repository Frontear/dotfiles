{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
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

          ../hosts/common
          (import ../hosts/laptop { inherit nixos-hardware; })
        ];
      };

      "nixos" = extLib.nixosSystem {
        modules = [
          self.nixosModules.default
          self.nixosModules.new

          ../hosts/common
          (import ../hosts/desktop-wsl { inherit nixos-wsl; })
        ];
      };
    };

    nixosModules.default = import ../modules { };

    nixosModules.new = import ../nmodules inputs;
  };
}
