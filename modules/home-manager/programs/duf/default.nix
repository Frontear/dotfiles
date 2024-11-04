{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.duf;
in {
  options = {
    my.programs.duf = {
      enable = lib.mkDefaultEnableOption "duf";
      package = lib.mkPackageOption pkgs "duf" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.shellAliases = {
      df = lib.getExe cfg.package;
    };
  };
}
