{
  lib,
  ...
}:
let
  self' = {
    systemPath = lib.types.path;
    userPath = lib.types.either self'.systemPath (lib.types.strMatching "~/[^~]+");
  };
in
  self'