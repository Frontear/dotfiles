{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  perSystem = { pkgs, ... }: {
    packages = lib.mkPackages pkgs ../../pkgs;
  };
}
