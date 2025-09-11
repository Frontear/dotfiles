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
          nixos-hardware.nixosModules.dell-inspiron-14-5420
          nixos-hardware.nixosModules.common-hidpi

          ../../hosts/laptop
        ];
      }
      {
        hostName = "ISO-3DT4F02";
        modules = [
          ../../hosts/iso
        ];
      }
    ];
  };
}