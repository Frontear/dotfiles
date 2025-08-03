{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.fd;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
