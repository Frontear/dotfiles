{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.powertop;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [ "/var/cache/powertop" ];

    environment.systemPackages = [
      cfg.package
    ];
  };
}
