{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gvfs;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/share/gvfs-metadata";
      unique = false; # Files are shared across specialisations.
    }];
  };
}