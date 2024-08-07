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

  lib = nixpkgs.lib.extend (_: prev: import ../../lib {
    inherit self;
    lib = prev;
  });

  mkNixOSConfigurations = (system: list:
  let
    mapSystemAttrs = lib.mapAttrs (_: value: if value ? "${system}" then value."${system}" else value);

    # Customized "self" reference that removes the necessity of system
    # for system-specific outputs, and leaves all other values as-is.
    # This is how flakes should've always been.
    self' = builtins.removeAttrs (mapSystemAttrs self) [ "inputs" "outputs" "sourceInfo" ]; # remove inputs and unnecessary outputs (their inner-attrs are available in self.*)
  in lib.listToAttrs (
    map (x: {
      name = x.hostName;
      value = lib.nixosSystem {
        specialArgs = {
          self = self';
        };
        modules = lib.concatLists [
          [ self.nixosModules.default ]
          [{
            networking.hostName = x.hostName;
            nixpkgs.hostPlatform = system;
          }]
          x.modules
        ];
      };
    }) list
  ));
in {
  flake.nixosConfigurations = mkNixOSConfigurations "x86_64-linux" [
    {
      hostName = "LAPTOP-3DT4F02";
      modules = [
        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-cpu-intel # pulls common-gpu-intel
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ../../hosts/laptop
      ];
    }
    {
      hostName = "DESKTOP-3DT4F02";
      modules = [
        nixos-wsl.nixosModules.default

        ../../hosts/desktop-wsl
      ];
    }
  ];
}