{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.patool;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
