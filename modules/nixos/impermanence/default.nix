{ inputs, config, lib, ... }:
with lib;
let
  cfg = config.impermanence;

  mkImpermanenceOptions = type: {
    directories = mkOption {
      type = types.listOf types.anything;
      default = [];
      description = ''
      List of ${type} directories to store persistently.
      '';
    };

    files = mkOption {
      type = types.listOf types.anything;
      default = [];
      description = ''
      List of ${type} files to store persistently.
      '';
    };
  };
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.impermanence = {
    enable = mkEnableOption "impermanence support";

    system = mkImpermanenceOptions "system";
    user = mkImpermanenceOptions "user";
  };

  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = {
      hideMounts = true;

      directories = [] ++ cfg.system.directories;
      files = [] ++ cfg.system.files;

      # TODO: needs changing
      users.frontear = {
        directories = [] ++ cfg.user.directories;
        files = [] ++ cfg.user.files;
      };
    };
  };
}