{
  self,
  lib,
  ...
}:
let
  callLibs = file: import file { inherit self lib; };
in {
  flake = (callLibs ./flake.nix) // (lib.flake or {});
  types = (callLibs ./types.nix) // (lib.types or {});
}
