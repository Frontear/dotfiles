{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware.bluetooth;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "/var/lib/bluetooth";
      unique = false;
    }];
  };
}