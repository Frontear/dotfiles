{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.inxi;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
