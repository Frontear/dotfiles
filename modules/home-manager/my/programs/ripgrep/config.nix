{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.ripgrep;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}