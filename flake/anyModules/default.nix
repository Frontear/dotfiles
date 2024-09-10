{
  self,
  inputs,
  ...
}:
{
  flake = {
    nixosModules.default = ({
      imports = [
        inputs.home-manager.nixosModules.default

        (self.lib.flake.mkModules "${self}/modules/common" {})
        (self.lib.flake.mkModules "${self}/modules/nixos" {
          inherit inputs;
        })

        "${self}/users"
      ];

      home-manager.sharedModules = [
        (self.lib.flake.mkModules "${self}/modules/home-manager" {})
      ];
    });
  };
}
