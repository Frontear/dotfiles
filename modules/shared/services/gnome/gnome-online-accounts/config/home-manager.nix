{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gnome.gnome-online-accounts;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/goa-1.0";
      unique = true;
    }];
  };
}