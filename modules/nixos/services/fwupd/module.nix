{
  config,
  lib,
  ...
}:
let
  cfg = config.services.fwupd;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = "/var/cache/fwupd";
        unique = false;
      }
      {
        path = "/var/lib/fwupd";
        unique = false;
      }
    ];
  };
}