{
  self,
  lib,
  ...
}:
let
  callLibs = name: file: lib.recursiveUpdate (lib.${name} or {}) (import file { inherit self lib; });
in {
  flake = callLibs "flake" ./flake.nix;
  types = callLibs "types" ./types.nix;
}
