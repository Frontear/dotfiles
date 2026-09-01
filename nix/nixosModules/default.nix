{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    home-manager
    nixos-facter-modules
    nix-index-database
    stylix
    ;

  inherit (self) lib;
in {
  flake = {
    nixosModules.default = {
      imports = [
        (lib.mkModules ../../modules {
          inherit inputs;
        })

        home-manager.nixosModules.default
        nixos-facter-modules.nixosModules.facter
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
            nix-index-database.homeModules.default

            {
              config.stylix.autoEnable = false;
            }
          ];
        };
      };
    };
  };
}