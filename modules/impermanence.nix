{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption types;

  cfg = config.impermanence;

  mkImpermanenceOption = name: {
    directories = lib.mkOption {
      type = types.listOf types.anything;
      default = [];
      description = mdDoc ''
      Directories from the ${name} to persist.
      '';
    };

    files = mkOption {
      type = types.listOf types.anything;
      default = [];
      description = mdDoc ''
      Files from the ${name} to persist.
      '';
    };
  };
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options = {
    impermanence = {
      enable = mkEnableOption "the usage of impermanence, a nix-community module designed to achieve an ephemeral running root system";

      root = mkImpermanenceOption "system";
      user = mkImpermanenceOption "user";
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
