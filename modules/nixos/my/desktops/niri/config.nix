{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    services.pipewire.enable = true;


    my.persist.directories = [{
      path = "/var/cache/tuigreet";
      unique = true;
    }];

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = ''${lib.getExe pkgs.tuigreet} --greeting "Welcome to NixOS (${lib.versions.majorMinor lib.version})!" --time --remember --asterisks'';
      };
    };


    environment.sessionVariables = {
      "NIXOS_OZONE_WL" = 1;
    };

    programs.niri = {
      enable = true;
    };

    # This is being overriden from what Niri provides by default so that it can
    # support other file-managers besides Nautilus, since the GNOME Portal only
    # defaults to Nautilus for the file chooser dialog.
    #
    # see: https://github.com/YaLTeR/niri/blob/a1dccedbb72da372d2a8a84022f37ccaa4d4a6e6/resources/niri-portals.conf
    xdg.portal.config.niri = {
      default = [ "gnome" "gtk" ];

      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };
}