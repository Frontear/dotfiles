{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.rofi;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
