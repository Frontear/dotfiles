{
  lib,
  ...
}:
{
  config = {
    # Niri "specialisation" (default)
    my.desktops.niri.enable = true;

    # GNOME specialisation
    specialisation.gnome.configuration = {
      my.desktops.gnome.enable = true;

      my.desktops.niri.enable = lib.mkForce false;
    };
  };
}