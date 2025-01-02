{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.direnv;
in {
  options.my.programs.direnv = {
    enable = lib.mkDefaultEnableOption "direnv";
    package = lib.mkOption {
      default = pkgs.direnv;
      defaultText = "pkgs.direnv";
      description = ''
        The direnv package to use.
      '';

      type = with lib.types; package;
    };

    config = lib.mkOption {
      default = {};
      description = ''
        Configuration for direnv. See `man 1 direnv.toml` for a full list of options.
      '';

      type = (pkgs.formats.toml {}).type;
    };

    nix-direnv = {
      enable = lib.mkDefaultEnableOption "direnv.nix-direnv";
      package = lib.mkOption {
        default = pkgs.nix-direnv.override { nix = osConfig.nix.package; };
        defaultText = "pkgs.nix-direnv";
        description = ''
          The nix-direnv package to use.
        '';

        type = with lib.types; package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [ cfg.package ];

    programs.direnv = {
      enable = true;
      package = cfg.package;

      config = cfg.config;

      nix-direnv.enable = cfg.nix-direnv.enable;
      nix-direnv.package = cfg.nix-direnv.package;
    };
  };
}
