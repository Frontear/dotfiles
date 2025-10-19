{
  config,
  lib,
  ...
}:
let
  cfg = config.services.fprintd;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "/var/lib/fprint";
      unique = false;
    }];
  };
}