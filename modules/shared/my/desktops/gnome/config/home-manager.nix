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

    dconf = {
      settings = {
        "org/gnome/shell" = {
          # Enable all extensions that the user configured
          enabled-extensions = cfg.extensions
            # TODO: error when invalid package given?
            |> lib.map (drv: drv.extensionUuid);

          # Prevent GNOME Tour from appearing on first startup.
          welcome-dialog-last-shown-version = pkgs.gnome-shell.version;
        };
      };
    };

    home.packages = cfg.extensions;

    # Prevent the GNOME initial setup screen from ever appearing.
    xdg.configFile."gnome-initial-setup-done".text = ''
      yes
    '';
  };
}