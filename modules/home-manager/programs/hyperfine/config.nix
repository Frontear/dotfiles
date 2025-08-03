{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.hyperfine;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
