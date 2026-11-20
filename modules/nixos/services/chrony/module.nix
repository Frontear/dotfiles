{
  config,
  lib,
  ...
}:
let
  cfg = config.services.chrony;
in {
  config = lib.mkMerge [
    # Chrony is a superior NTP daemon compared to systemd-timesyncd.
    # Frankly, the latter should never have been used at all.
    #
    # see: https://discourse.nixos.org/t/why-are-we-using-systemd-timesyncd-by-default/74052
    { services.chrony.enable = true; }

    (lib.mkIf cfg.enable {
      my.persist.directories = [{
        path = cfg.directory;
        unique = false;
      }];
    })
  ];
}