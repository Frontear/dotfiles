{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  flake = {
    overlays.default = _: prev: {
      frontear = lib.recurseIntoAttrs
        <| lib.mkPackages prev ../../pkgs;
    };
  };
}