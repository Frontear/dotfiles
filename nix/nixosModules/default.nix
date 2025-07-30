{
  self,
  inputs,
  ...
}:
let
  inherit (inputs) home-manager;

  inherit (self) lib;
in {
  flake.nixosModules.default = {
    imports = [
      home-manager.nixosModules.default

      (lib.mkModules ../../modules/common {})
      (lib.mkModules ../../modules/nixos {
        inherit inputs;
      })

      ../../users
    ];

    config.home-manager = {
      # TODO: remove this workaround once sd-switch is fixed.
      #
      # see: https://github.com/nix-community/home-manager/issues/7583
      enableLegacyProfileManagement = true;

      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = [
        (lib.mkModules ../../modules/home-manager {})
      ];
    };
  };
}
