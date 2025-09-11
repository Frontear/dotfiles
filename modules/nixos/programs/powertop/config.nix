{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.powertop;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "/var/cache/powertop";
      unique = true;
    }];

    environment.systemPackages = [
      cfg.package
    ];
  };
}