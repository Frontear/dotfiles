{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.cheat;

  format = pkgs.formats.yaml {};
in {
  options = {
    my.programs.cheat = {
      enable = lib.mkDefaultEnableOption "cheat";
      package = lib.mkPackageOption pkgs "cheat" {};

      settings = lib.mkOption {
        default = {};

        type = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [
      config.xdg.configFile."cheat/cheatsheets/community".source ];

    home.packages = [ cfg.package ];

    my.programs.cheat.settings = {
      cheatpaths = [
        {
          name = "community";
          path = "${config.xdg.configHome}/cheat/cheatsheets/community";
          tags = [ "community" ];
          readonly = true;
        }
      ];
    };

    xdg.configFile."cheat/conf.yml".source =
      format.generate "cheat-conf-yml" cfg.settings;

    xdg.configFile."cheat/cheatsheets/community".source =
      pkgs.fetchFromGitHub {
        owner = "cheat";
        repo = "cheatsheets";
        rev = "36bdb99";
        hash = "sha256-Afv0rPlYTCsyWvYx8UObKs6Me8IOH5Cv5u4fO38J8ns=";
      };
  };
}
