{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.patool;
in {
  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [
      cfg.package
    ];

    home.packages = [
      cfg.package
    ];
  };
}
