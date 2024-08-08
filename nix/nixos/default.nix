{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixos-hardware
    nixos-wsl
    nixpkgs
    ;

  lib = nixpkgs.lib.extend (_: prev: import "${self}/lib" {
    inherit self;
    lib = prev;
  });
in {
  flake = {
    nixosModules.default = lib.flake.mkModules "${self}/modules";

    nixosConfigurations = lib.flake.mkNixOSConfigurations "x86_64-linux" [
      {
        hostName = "LAPTOP-3DT4F02";
        modules = [
          nixos-hardware.nixosModules.dell-inspiron-14-5420
          nixos-hardware.nixosModules.common-hidpi

          "${self}/hosts/laptop"
        ];
      }
      {
        hostName = "DESKTOP-3DT4F02";
        modules = [
          nixos-wsl.nixosModules.default

          "${self}/hosts/desktop-wsl"
        ];
      }
    ];
  };
}