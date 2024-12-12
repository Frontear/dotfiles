{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.fd;
in {
  options = {
    my.programs.fd = {
      enable = lib.mkDefaultEnableOption "fd";
      package = lib.mkPackageOption pkgs "fd" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
