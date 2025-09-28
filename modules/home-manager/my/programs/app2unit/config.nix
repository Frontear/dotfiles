{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.app2unit;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}