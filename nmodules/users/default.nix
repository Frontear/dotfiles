{
  config,
  lib,
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

      packages = mkOption {
        default = [];
        description = ''
          List of packages to install at the user-level.
        '';
        type = types.listOf types.package;
      };

      initialHashedPassword = mkOption {
        default = null;
        description = ''
          See users.users.${name}.initialHashedPassword for details.
        '';
        type = with types; nullOr (passwdEntry str);
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

      inherit (value) packages initialHashedPassword;
    };
  }) config.my.users);
}