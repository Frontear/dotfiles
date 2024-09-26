{
  lib,
  ...
}:
let
  mkPathOption = user: group: mode: type: apply: {
    options = {
      path = lib.mkOption {
        default = null;

        inherit apply type;
      };

      user = lib.mkOption {
        default = user;

        type = with lib.types; passwdEntry str;
      };

      group = lib.mkOption {
        default = group;

        type = with lib.types; str;
      };

      mode = lib.mkOption {
        default = mode;

        type = with lib.types; str;
      };
    };
  };

  mkPersistOption = user: group: type: apply: {
    enable = lib.mkEnableOption "impermanence";

    volume = lib.mkOption {
      default = "/nix/persist";

      type = with lib.types; path;
    };

    directories = lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo str (path: { inherit path; }) (submodule (mkPathOption user group "755" type apply)));
    };

     files = lib.mkOption {
      default = [];

      type = with lib.types; listOf (coercedTo str (path: { inherit path; }) (submodule (mkPathOption user group "644" type apply)));
    };
  };
in {
  options.my.persist = mkPersistOption "root" "root" (with lib.types; systemPath) (x: x);

  config = {
    # Add the module into the home-manager context.
    home-manager.sharedModules = lib.singleton (
    {
      osConfig,
      config,
      ...
    }:
    {
      options.my.persist = lib.removeAttrs (mkPersistOption config.home.username osConfig.users.extraUsers.${config.home.username}.group (with lib.types; userPath) (lib.replaceStrings [ "~" ] [ config.home.homeDirectory ])) [ "enable" "volume" ]; # strip enable and volume options, they are irrelevant for home-manager.
    });
  };
}
