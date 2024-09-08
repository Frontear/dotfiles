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
    ;

  inherit (self) lib;
in {
  flake = {
    nixosModules.default = lib.flake.mkModules "${self}/modules/nixos" {
      inherit inputs;
    };

    homeManagerModules.default = lib.flake.mkModules "${self}/modules/home-manager" {};

    nixosConfigurations = lib.flake.mkNixOSConfigurations "x86_64-linux" [
      {
        hostName = "LAPTOP-3DT4F02";
        modules = [
          nixos-hardware.nixosModules.dell-inspiron-14-5420
          nixos-hardware.nixosModules.common-hidpi

          home-manager.nixosModules.default

          ({ ... }: {
            imports = [
              "${self}/modules/common/persist" # TODO: fix this
            ];
          })

          ({
            home-manager.sharedModules = [
              self.homeManagerModules.default
            ];
          })

          "${self}/hosts/laptop"
          "${self}/users"
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
  };
}