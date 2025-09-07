{
  lib,
  ...
}:
let
  pathSubmodule = {
    options = {
      path = lib.mkOption {
        type = with lib.types; path;
      };

      unique = lib.mkOption {
        default = false;

        type = with lib.types; bool;
      };
    };
  };

  mkOption' = { coercedType, coercedFunc, } :
    lib.genAttrs [ "directories" "files" ] (_: lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo coercedType
        coercedFunc (submodule pathSubmodule));
    });
in {
  options = {
    my.persist = mkOption' {
      coercedType = with lib.types; systemPath;
      coercedFunc = path: { inherit path; };
    };
  };

  config = {
    home-manager.sharedModules = [({ config, ... }: {
      options = {
        my.persist = mkOption' {
          coercedType = with lib.types; userPath;
          coercedFunc = path: {
            path =
              lib.replaceStrings [ "~" ] [ config.home.homeDirectory ] path;
          };
        };
      };
    })];
  };
}
