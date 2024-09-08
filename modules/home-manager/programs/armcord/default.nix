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
    my.persist.directories = [ "~/.config/ArmCord" ];

    home.packages = [ config.my.programs.armcord.package ];
  };
}