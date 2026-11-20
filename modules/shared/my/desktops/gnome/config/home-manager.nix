{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.gnome;

  persistDirs = [
    "~/.cache/mesa_shader_cache"

    "~/.config/enchant"

    "~/.local/share/gnome-shell"
    "~/.local/share/nautilus"
    "~/.local/share/org.gnome.TextEditor"
    "~/.local/share/pki"
  ];

  persistFiles = [
    "~/.config/.gsd-keyboard.settings-ported"
    "~/.config/monitors.xml"
  ];

  mkPersist = lib.map (path: {
    inherit path;
    unique = true;
  });
in {
  config = lib.mkIf cfg.enable {
    my.persist = {
      directories = mkPersist persistDirs;
      files = mkPersist persistFiles;
    };

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