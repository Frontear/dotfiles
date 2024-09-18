{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    home-manager
    ;

  inherit (self) lib;
in {
  flake.nixosModules.default = ({
    imports = [
      home-manager.nixosModules.default

      (lib.flake.mkModules ./common {})
      (lib.flake.mkModules ./nixos {
        inherit inputs;
      })

      # TODO: this is NOT right
      "${self}/users"
    ];

    home-manager.sharedModules = [
      (lib.flake.mkModules ./home-manager {})
    ];
  });
}
