{
  config,
  lib,
  pkgs,
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

    # Prevent the GNOME initial setup screen from ever appearing.
    xdg.configFile."gnome-initial-setup-done".text = ''
      yes
    '';

    dconf = {
      settings = {
        "org/gnome/shell" = {
          # Prevent GNOME Tour from appearing on first startup.
          welcome-dialog-last-shown-version = pkgs.gnome-shell.version;
        };
      };
    };
  };
}