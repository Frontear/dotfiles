{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    home-manager
    stylix
    ;

  inherit (self) lib;
in {
  flake = {
    nixosModules.default = {
      imports = [
        home-manager.nixosModules.default

        (lib.mkModules ../../modules/common {})
        (lib.mkModules ../../modules/nixos {
          inherit inputs;
        })

        ../../users
      ];

      config = {
        nixpkgs.overlays = [
          self.overlays.default
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          sharedModules = [
            stylix.homeModules.stylix
            { config.stylix.autoEnable = false; }

            (lib.mkModules ../../modules/home-manager {})
          ];
        };
      };
    };
  };
}