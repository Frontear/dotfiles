{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  flake = {
    overlays.default = final: prev: lib.mkPackages prev ../../pkgs;
  };
}
