{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.eza;
in {
  options.my.programs.eza = {
    enable = lib.mkDefaultEnableOption "eza";
    package = lib.mkOption {
      default = pkgs.eza;
      defaultText = "pkgs.eza";
      description = ''
        The eza package to use.
      '';

      type = with lib.types; package;
    };

    extraOptions = lib.mkOption {
      default = [];
      description = ''
        Extra cli arguments passed to eza.
      '';

      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      package = cfg.package;

      extraOptions = cfg.extraOptions;
    };
  };
}
