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

  lib = nixpkgs.lib.extend (final: prev: import ../lib {
    inherit self;
    lib = prev;
  });
in {
  perSystem = { pkgs, ... }: {
    devShells.default = import ./shell.nix { inherit pkgs; };
  };

  flake = {
    nixosConfigurations = lib.flake.mkHostConfigurations "x86_64-linux" [{
      hostName = "LAPTOP-3DT4F02";
      modules = [
        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-cpu-intel # pulls common-gpu-intel
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ../hosts/laptop
      ];
    }
    {
      hostName = "DESKTOP-3DT4F02";
      modules = [
        nixos-wsl.nixosModules.default

        ../hosts/desktop-wsl
      ];
    }];

    nixosModules.default = (
      {
        lib,
        ...
      }:
      {
        imports = lib.importsRecursive ../modules (x: x == "default.nix");

        config._module.args = { inherit inputs; };
      }
    );
  };
}
