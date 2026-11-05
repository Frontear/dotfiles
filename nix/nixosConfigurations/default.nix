{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixos-hardware
    ;

  inherit (self) lib;
in {
  flake = {
    nixosConfigurations = lib.mkNixOSConfigurations "x86_64-linux" [
      {
        hostName = "LAPTOP-3DT4F02";
        modules = [
          "${nixos-hardware}/framework/13-inch/intel-core-ultra-series3"

          ../../hosts/framework-13-pro
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