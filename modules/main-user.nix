{
  config,
  lib,
  ...
}:
let
  inherit (lib) mdDoc mkOption types;

  cfg = config.main-user;
in {
  options = {
    main-user = {
      name = mkOption {
        type = types.str;
        description = mdDoc ''
        Username of the main user on this system.
        '';
      };

      extraConfig = mkOption {
        type = types.anything;
        description = mdDoc ''
        Extra options that are passed directly to users.extraUsers.$\{username}
        '';
      };
    };
  };

  config = {
    users.extraUsers."${cfg.name}" = {
      isNormalUser = true;
    } // cfg.extraConfig;
  };
}
