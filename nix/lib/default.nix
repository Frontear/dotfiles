{
  self,
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
in {
  flake = {
    lib = lib.extend (_: prev: import "${self}/lib" {
      inherit self;
      lib = prev;
    });
  };
}