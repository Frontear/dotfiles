{
  lib,
  ...
}:
let
  utils = import ../_utils.nix { inherit lib; };
in {
  options = {
    my.persist = utils.mkOption' {
      coercedType = with lib.types; systemPath;
      coercedFunc = lib.id;

      # System state usually wants to be shared
      unique = false;
    };
  };
}