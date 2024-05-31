{ config, lib, ... }:
let
  inherit (lib) mkOption types mkMerge;

  cfg = config.home;
in {
  options.home = {
    file = mkOption {
      # TODO: proper attr definition
      type = types.anything;
      default = { };
      description = ''
        Attribute set of files to link into the user home.
      '';
    };
  };

  config = { home-manager.users.frontear.home.file = mkMerge [ cfg.file ]; };
}
