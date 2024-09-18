{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    ;
in {
  flake.lib = nixpkgs.lib.extend (_: prev:
  let
    callLib = (file: name:
      prev.recursiveUpdate (prev.${name} or {}) (import file {
        inherit self;
        lib = prev;
      })
    );
  in {
    flake = callLib ./flake.nix "flake";
    types = callLib ./types.nix "types";
  });
}
