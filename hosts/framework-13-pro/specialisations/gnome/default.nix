{
  lib,
  ...
}:
{
  # The GNOME specialisation, used for school work, with my GNOME environment.
  specialisation.gnome.configuration = {
    my.desktops.niri.enable = lib.mkForce false;
    my.desktops.gnome.enable = true;
  };
}