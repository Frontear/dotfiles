{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.gnome.evolution-data-server;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = "~/.cache/evolution";
        unique = true;
      }
      {
        path = "~/.config/evolution";
        unique = true;
      }
      {
        path = "~/.local/share/evolution";
        unique = true;
      }
    ];
  };
}