{
  self,
  inputs,
  ...
}:
let
  inherit (self) lib;
in {
  flake = {
    nixosConfigurations = lib.mkNixOSConfigurations "x86_64-linux" [
      {
        hostName = "LAPTOP-3DT4F02";
        modules = [
          ../../hosts/laptop
        ];
      }
      {
        hostName = "ISO-3DT4F02";
        modules = [
          ../../hosts/iso
        ];

        specialArgs = {
          inputs = {
            nixos-facter =
              lib.flakes.stripSystem "x86_64-linux" inputs.nixos-facter;
          };
        };
      }
    ];
  };
}