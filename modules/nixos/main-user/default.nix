{ config, lib, ... }:
with lib;
let
  cfg = config.main-user;
in {
  options.main-user = {
    name = mkOption {
      type = types.str;
      description = ''
      Username of the system's main user.
      '';
    };

    home = mkOption {
      type = types.path;
      description = ''
      Home directory of the system's main user.
      This is here to avoid a Nixpkgs infinite recursion issue.
      See https://github.com/NixOS/nixpkgs/issues/24570.
      '';
    };

    extraConfig = mkOption {
      type = types.anything;
      default = {};
      description = ''
      Extra configuration passed directly to config.users.users.''${config.main-user.name}.
      '';
    };
  };

  config = {
    users.users.${cfg.name} = mkMerge [
      {
        isNormalUser = true;
      }

      cfg.extraConfig
    ];
  };
}
