{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.desktops.gnome = {
      enable = lib.mkEnableOption "gnome" // {
        default = osConfig.my.desktops.gnome.enable;
      };
    };
  };
}