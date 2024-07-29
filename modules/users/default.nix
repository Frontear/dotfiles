{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrsToList mkMerge mkOption types;

  userOpts = { name, ... }: {
    options = {
      username = mkOption {
        default = name;
        description = ''
          The username of the user.
        '';
        type = types.passwdEntry types.str;
      };

      homeDirectory = mkOption {
        default = "/home/${name}";
        description = ''
          The home directory path for the user.
        '';
        type = types.passwdEntry types.path;
      };

      initialHashedPassword = mkOption {
        default = null;
        description = ''
          See users.users.${name}.initialHashedPassword for further details.
        '';
        type = with types; nullOr (passwdEntry str);
      };

      packages = mkOption {
        default = [];
        description = ''
          Ideally prefer user modules over adding packages here.

          See users.users.${name}.packages for further details.
        '';
        type = types.listOf types.package;
      };

      shell = mkOption {
        default = pkgs.shadow;
        description = ''
          Do not set this manually unless you wish to forgo
          the shell modules.

          See users.users.${name}.shell for further details.
        '';
      };
    };
  };
in {
  imports = [
    ./programs
  ];

  options = {
    my.users = mkOption {
      default = {};
      description = ''
        User accounts to create. All users created via these options are intended to be non-system users.
      '';
      type = with types; attrsOf (submodule userOpts);
    };
  };

  config.users.extraUsers = mkMerge (mapAttrsToList (name: value: {
    "${name}" = {
      name = value.username;
      home = value.homeDirectory;
      isNormalUser = true;

      inherit (value) initialHashedPassword packages shell;
    };
  }) config.my.users);
}