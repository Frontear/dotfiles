{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gnome.gnome-keyring;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/share/keyrings";
      unique = true;
    }];
  };
}