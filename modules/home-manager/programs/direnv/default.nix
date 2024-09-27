{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.programs.direnv.enable {
    programs.direnv = {
      enable = true;
      package = config.my.programs.direnv.package;

      config = config.my.programs.direnv.config;

      nix-direnv.enable = config.my.programs.direnv.nix-direnv.enable;
      nix-direnv.package = config.my.programs.direnv.nix-direnv.package;
    };
  };
}
