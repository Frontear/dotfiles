{
  lib,
  ...
}:
{
  options = {
    my.desktops.gnome = {
      enable = lib.mkEnableOption "gnome";
    };
  };
}