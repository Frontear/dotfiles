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
  flake.nixosModules.default = { pkgs, ... }: {
    imports = [
      home-manager.nixosModules.default

      (lib.mkModules ../../modules/common {})
      (lib.mkModules ../../modules/nixos {
        inherit inputs;
      })

      ../../users
    ];

    config.home-manager = {
      extraSpecialArgs = {
        self = lib.stripSystem pkgs.system self;
      };

      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = [
        stylix.homeModules.stylix
        { config.stylix.autoEnable = false; }

        (lib.mkModules ../../modules/home-manager {})
      ];
    };
  };
}
