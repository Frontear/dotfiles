{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.armcord = {
    enable = lib.mkEnableOption "armcord";
    package = lib.mkOption {
      default = pkgs.armcord;
      defaultText = "pkgs.armcord";
      description = ''
        The armcord package to use.
      '';

      type = with lib.types; package;
    };
  };

  config = lib.mkIf config.my.programs.armcord.enable {
    warnings = [
      "WARN: Impermanence not configured! (persist ~/.config/ArmCord)"
    ];

    home.packages = [ config.my.programs.armcord.package ];
  };
}