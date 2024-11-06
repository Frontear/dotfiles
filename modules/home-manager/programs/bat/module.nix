{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.bat;
in {
  options = {
    my.programs.bat = {
      enable = lib.mkDefaultEnableOption "bat";
      package = lib.mkPackageOption pkgs "bat" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.shellAliases = {
      cat = lib.getExe cfg.package;
    };
  };
}
