{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  imports = [
    ./cachix.nix
  ];

  perSystem = { pkgs, ... }: {
    packages = lib.mkPackages pkgs ../../pkgs;
  };
}
