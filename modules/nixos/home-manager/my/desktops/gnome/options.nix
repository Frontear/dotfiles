{
  nixosConfig,
  lib,
  ...
}:
{
  options = {
    my.desktops.gnome = {
      enable = lib.mkEnableOption "gnome" // {
        default = nixosConfig.my.desktops.gnome.enable;

        readOnly = true;
      };
    };
  };
}