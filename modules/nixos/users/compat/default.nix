{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrsToList mkMerge mkOption optionalString types;

  mkCompatOption = { cfg, default, description ? null, type }: mkOption {
    inherit default type;
    description = ''
      Exposed configuration for users.users.<name>.${cfg}.
    '' + (optionalString (description != null) ''
      ${description}
    '');
  };

  userOpts = { ... }: {
    options = {
      packages = mkCompatOption {
        cfg = "packages";
        default = [];
        description = ''
          Prefer using modules instead.
        '';

        type = with types; listOf package;
      };
    };
  };
in {
  options = {
    my.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
    };
  };

  config.users.extraUsers = mkMerge (mapAttrsToList (name: value: {
    "${name}" = {
      inherit (value) packages;
    };
  }) config.my.users);
}