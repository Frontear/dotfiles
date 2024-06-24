{ impermanence, ... }: ({ config, lib, ... }:
let
  inherit (lib) mkOption types mkEnableOption mkIf;

  cfg = config.impermanence;

  mkImpermanenceOption = type: {
    directories = mkOption {
      type = types.listOf types.anything;
      default = [ ];
      description = ''
        List of ${type} directories to store persistently.
      '';
    };

    files = mkOption {
      type = types.listOf types.anything;
      default = [ ];
      description = ''
        List of ${type} files to store persistently.
      '';
    };
  };
in {
  imports = [ impermanence.nixosModules.impermanence ];

  options.impermanence = {
    enable = mkEnableOption "impermanence support";

    system = mkImpermanenceOption "system";
    user = mkImpermanenceOption "user";
  };

  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = {
      hideMounts = true;

      directories = [ ] ++ cfg.system.directories;
      files = [ ] ++ cfg.system.files;

      # TODO: needs changing
      users.frontear = {
        directories = [ ] ++ cfg.user.directories;
        files = [ ] ++ cfg.user.files;
      };
    };
  };
})