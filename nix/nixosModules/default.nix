{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    home-manager
    nixos-facter-modules
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
            { config.stylix.autoEnable = false; }
          ];
        };
      };
    };
  };
}