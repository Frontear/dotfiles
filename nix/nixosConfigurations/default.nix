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
          "${nixos-hardware}/common/cpu/intel/tiger-lake/cpu-only.nix"
          "${nixos-hardware}/common/gpu/intel/tiger-lake"
          "${nixos-hardware}/common/pc/laptop"
          "${nixos-hardware}/common/pc/ssd"
          "${nixos-hardware}/common/hidpi.nix"

          ../../hosts/laptop
        ];
      }
      {
        hostName = "ISO-3DT4F02";
        modules = [
          ../../hosts/iso
        ];

        specialArgs = {
          nixos-facter =
            inputs.nixos-facter.packages."x86_64-linux".nixos-facter;
        };
      }
    ];
  };
}