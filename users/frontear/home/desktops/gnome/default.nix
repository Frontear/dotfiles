{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  imports = [
    ./stylix
  ];

  config = lib.mkIf cfg.enable {
    my.programs = {
      microsoft-edge.enable = true;
      legcord.enable = true;
      libreoffice.enable = true;
    };

    programs.obs-studio.enable = true;

    dconf = {
      settings = {
        # Automatic brightness change causes flickering
        "org/gnome/settings-daemon/plugins/power" = {
          ambient-enabled = false;
        };

        # Show weekday on top bar
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };

        # Allow GNOME to get my location, mostly for the night light
        "org/gnome/system/location" = {
          enabled = true;
        };

        # Configuring the night light
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-temperature = lib.gvariant.mkUint32 3200;

          # Requires location information to get sunrise/sunset timings
          night-light-schedule-automatic = true;
        };
      };
    };
  };
}