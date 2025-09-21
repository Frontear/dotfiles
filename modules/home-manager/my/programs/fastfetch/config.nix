{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.fastfetch;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}