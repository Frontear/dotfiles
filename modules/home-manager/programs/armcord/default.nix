{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.legcord;
in {
  imports = [
    (lib.mkAliasOptionModule [ "my" "programs" "armcord" ] [ "my" "programs" "legcord" ])
  ];

  options.my.programs.legcord = {
    enable = lib.mkEnableOption "legcord";
    package = lib.mkOption {
      default = pkgs.legcord;

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [ "~/.config/legcord" ];

    home.packages = [ cfg.package ];
  };
}
