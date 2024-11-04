{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.doggo;
in {
  options = {
    my.programs.doggo = {
      enable = lib.mkDefaultEnableOption "doggo";
      package = lib.mkPackageOption pkgs "doggo" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.shellAliases = {
      dig = lib.getExe cfg.package;
    };
  };
}
