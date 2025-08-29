{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  flake = {
    overlays.default = final: prev: {
      frontear = lib.recurseIntoAttrs
        <| lib.mkPackages prev ../../pkgs;
    };
  };
}
