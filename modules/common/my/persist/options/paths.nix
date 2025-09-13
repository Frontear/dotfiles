{
  lib,
  ...
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

  mkOption' = { coercedType, coercedFunc, unique }:
    lib.genAttrs [ "directories" "files" ] (_: lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo coercedType (path: {
        inherit path unique;
      }) (submodule (pathSubmodule coercedType coercedFunc)));
    });
in {
  options = {
    my.persist = mkOption' {
      coercedType = with lib.types; systemPath;
      coercedFunc = lib.id;

      # System state usually wants to be shared
      unique = false;
    };
  };

  config = {
    home-manager.sharedModules = [({ config, ... }: {
      options = {
        my.persist = mkOption' {
          coercedType = with lib.types; userPath;
          coercedFunc = lib.replaceStrings [ "~" ] [ config.home.homeDirectory ];

          # User state usually wants to be unique
          unique = true;
        };
      };
    })];
  };
}