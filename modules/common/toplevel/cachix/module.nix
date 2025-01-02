{
  config,
  lib,
  ...
}:
let
  path = lib.splitString "." <| "my.toplevel.cachix";
  commonOpts = lib.mkOption {
    default = [];

    type = with lib.types; listOf package;
  };
in {
  options = lib.setAttrByPath path commonOpts;

  config = {
    my.toplevel.cachix = lib.attrValues config.home-manager.users
      |> map (config: config.my.toplevel.cachix)
      |> lib.flatten;

    home-manager.sharedModules = [{
      options = lib.setAttrByPath path commonOpts;
    }];
  };
}
