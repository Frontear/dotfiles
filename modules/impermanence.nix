{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mdDoc mkIf mkOption types;

  cfg = config.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options = {
    impermanence = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
        Enables the usage of impermanence, a nix-community module designed
        to achieve an ephemeral running root system.
        '';
      };

      root = {
        directories = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = mdDoc ''
          Directories from the system to persist.
          '';
        };

        files = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = mdDoc ''
          Files from the system to persist.
          '';
        };
      };

      user = {
        directories = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = mdDoc ''
          Directories from the user to persist.
          '';
        };

        files = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = mdDoc ''
          Files from the user to persist.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = {
      hideMounts = true;

      directories = [] ++ cfg.root.directories;
      files = [] ++ cfg.root.files;

      # TODO: change
      users.frontear = {
        directories = [] ++ cfg.user.directories;
        files = [] ++ cfg.user.files;
      };
    };
  };
}
