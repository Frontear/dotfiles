{
  config,
  lib,
  ...
}:
let
  utils = import ./_utils.nix { inherit lib; };
in {
  options = {
    my.persist = utils.mkOption' {
      coercedType = with lib.types; userPath;
      coercedFunc = lib.replaceStrings [ "~" ] [ config.home.homeDirectory ];

      # User state usually wants to be unique
      unique = true;
    };
  };
}