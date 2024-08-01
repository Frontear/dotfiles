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
      initialHashedPassword = mkCompatOption {
        cfg = "initialHashedPassword";
        default = null;

        type = with types; nullOr (passwdEntry str);
      };

      packages = mkCompatOption {
        cfg = "packages";
        default = [];
        description = ''
          Prefer using modules instead.
        '';

        type = with types; listOf package;
      };

      shell = mkCompatOption {
        cfg = "shell";
        default = pkgs.shadow;
        description = ''
          Do **not** set this manually unless you know
          what you are doing!
        '';

        type = with types; nullOr (either shellPackage (passwdEntry path));
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
      inherit (value) initialHashedPassword packages shell;
    };
  }) config.my.users);
}