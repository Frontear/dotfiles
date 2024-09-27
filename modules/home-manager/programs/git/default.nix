{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.git;
in {
  options.my.programs.git = {
    enable = lib.mkDefaultEnableOption "git";
    package = lib.mkOption {
      default = pkgs.gitMinimal;
      defaultText = "pkgs.gitMinimal";
      description = ''
        The git package to use.
      '';

      type = with lib.types; package;
    };

    config = lib.mkOption {
      default = {};
      description = ''
        Configuration written to your git config.
      '';

      type = with lib.types; attrsOf (attrsOf anything);
    };

    ignores = lib.mkOption {
      default = [];
      description = ''
        List of paths that should be globally ignored.
      '';

      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = cfg.package;

      extraConfig = cfg.config;
      ignores = cfg.ignores;
    };
  };
}
