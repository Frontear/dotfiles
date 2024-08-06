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

  lib = nixpkgs.lib.extend (final: prev: import ../lib prev);
in {
  perSystem = { pkgs, ... }: {
    devShells.default = import ./shell.nix { inherit pkgs; };
  };

  flake = {
    nixosConfigurations = lib.flake.mkHostConfigurations "x86_64-linux" [{
      hostName = "LAPTOP-3DT4F02";
      modules = [
        self.nixosModules.default
        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-cpu-intel # pulls common-gpu-intel
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ../hosts/common
        ../hosts/laptop
      ];
    }
    {
      hostName = "DESKTOP-3DT4F02";
      modules = [
        self.nixosModules.default
        nixos-wsl.nixosModules.default

        ../hosts/common
        ../hosts/desktop-wsl
      ];
    }];

    nixosModules.default = import ../modules inputs;
  };
}
