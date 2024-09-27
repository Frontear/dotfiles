{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.armcord;
in {
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

  config = lib.mkIf cfg.enable {
    my.persist.directories = [ "~/.config/ArmCord" ];

    home.packages = [ cfg.package ];
  };
}
