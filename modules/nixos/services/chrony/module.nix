{
  config,
  lib,
  ...
}:
let
  cfg = config.services.chrony;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      cfg.directory
    ];
  };
}