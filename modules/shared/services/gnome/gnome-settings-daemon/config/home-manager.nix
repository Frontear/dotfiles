{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gnome.gnome-settings-daemon;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = "~/.local/share/gnome-settings-daemon";
        unique = true;
      }
    ];
  };
}