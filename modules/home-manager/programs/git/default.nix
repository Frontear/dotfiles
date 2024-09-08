{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.git = {
    enable = lib.mkEnableOption "git";
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

  config = lib.mkIf config.my.programs.git.enable {
    programs.git = {
      enable = true;
      package = config.my.programs.git.package;

      extraConfig = config.my.programs.git.config;
      ignores = config.my.programs.git.ignores;
    };
  };
}