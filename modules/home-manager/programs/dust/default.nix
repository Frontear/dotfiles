{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.dust;
in {
  options = {
    my.programs.dust = {
      enable = lib.mkDefaultEnableOption "dust";
      package = lib.mkPackageOption pkgs "dust" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.shellAliases = {
      du = lib.getExe cfg.package;
    };
  };
}
