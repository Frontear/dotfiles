{
  config,
  lib,
  ...
}:
let
  cfg = config.security.sudo;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "/var/db/sudo/lectured";
      unique = false;
    }];
  };
}