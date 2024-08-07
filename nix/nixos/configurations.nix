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

  lib = nixpkgs.lib.extend (_: prev: import "${self}/lib" {
    inherit self;
    lib = prev;
  });

  mkNixOSConfigurations = (system: list: lib.listToAttrs (
    map (x: {
      name = x.hostName;
      value = lib.nixosSystem {
        specialArgs = {
          self = lib.flake.mkSelf' system;
        };
        modules = lib.concatLists [
          [
            self.nixosModules.default
            {
              networking.hostName = x.hostName;
              nixpkgs.hostPlatform = system;
            }
          ]
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

        "${self}/hosts/laptop"
      ];
    }
    {
      hostName = "DESKTOP-3DT4F02";
      modules = [
        nixos-wsl.nixosModules.default

        "${self}/hosts/desktop-wsl"
      ];
    }
  ];
}