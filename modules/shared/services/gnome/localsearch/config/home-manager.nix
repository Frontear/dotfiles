{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gnome.localsearch;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.cache/tracker3";
      unique = false; # Files are shared across specialisations
    }];
  };
}