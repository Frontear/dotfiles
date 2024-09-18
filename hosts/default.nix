{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixos-hardware
    nixos-wsl
    ;

  inherit (self) lib;
in {
  flake.nixosConfigurations = lib.flake.mkNixOSConfigurations "x86_64-linux" [
    {
      hostName = "LAPTOP-3DT4F02";
      modules = [
        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-hidpi

        ./laptop
      ];
    }
    {
      hostName = "DESKTOP-3DT4F02";
      modules = [
        nixos-wsl.nixosModules.default

        ./desktop-wsl
      ];
    }
  ];
}
