{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  user-directory = ".config/microsoft-edge";
  persist-user-directory = "~/.config/microsoft-edge";

  userOpts = { config, ... }: {
    options.programs.microsoft-edge = {
      enable = mkEnableOption "microsoft-edge";
      package = mkOption {
        default = pkgs.microsoft-edge.override {
          commandLineArgs = "--user-data-dir=${user-directory}";
        };

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.microsoft-edge.enable {
      packages = [ config.programs.microsoft-edge.package ];

      persist.directories = [ persist-user-directory ];
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}
