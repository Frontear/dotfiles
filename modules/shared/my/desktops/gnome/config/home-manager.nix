{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    # TODO: determine what actually needs to be kept and what doesn't
    my.persist.directories = [
      {
        path = "~/.cache";
        unique = true;
      }
      {
        path = "~/.config";
        unique = true;
      }
      {
        path = "~/.local";
        unique = true;
      }
    ];
  };
}