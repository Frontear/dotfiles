{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.hyperfine;
in {
  options = {
    my.programs.hyperfine = {
      enable = lib.mkDefaultEnableOption "hyperfine";
      package = lib.mkPackageOption pkgs "hyperfine" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
