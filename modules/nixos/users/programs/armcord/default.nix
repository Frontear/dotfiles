{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.armcord = {
      enable = mkEnableOption "armcord";
      package = mkOption {
        default = pkgs.armcord;

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.armcord.enable {
      packages = [ config.programs.armcord.package ];

      persist.directories = [ "~/.config/ArmCord" ];
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}