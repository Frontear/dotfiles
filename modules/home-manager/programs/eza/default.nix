{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.eza = {
    enable = lib.mkEnableOption "eza" // { default = true; };
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

  config = lib.mkIf config.my.programs.eza.enable {
    programs.eza = {
      enable = true;
      package = config.my.programs.eza.package;

      extraOptions = config.my.programs.eza.extraOptions;
    };
  };
}