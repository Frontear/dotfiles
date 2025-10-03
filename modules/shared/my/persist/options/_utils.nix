{
  lib,
}:
let
  pathSubmodule = coercedType: coercedFunc: {
    options = {
      path = lib.mkOption {
        type = with lib.types; coercedTo coercedType coercedFunc path;
      };

      unique = lib.mkOption {
        type = with lib.types; bool;
      };
    };
  };
in {
  mkOption' = { coercedType, coercedFunc, unique }:
    lib.genAttrs [ "directories" "files" ] (_: lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo coercedType (path: {
        inherit path unique;
      }) (submodule (pathSubmodule coercedType coercedFunc)));
    });
}