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

      extensions = lib.mkOption {
        default = [];

        # TODO: more strict type-checking?
        type = with lib.types; listOf package;
      };
    };
  };
}