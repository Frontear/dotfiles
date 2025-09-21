{
  nixosConfig,
  lib,
  ...
}:
{
  options = {
    my.desktops.niri = {
      enable = lib.mkEnableOption "niri" // {
        default = nixosConfig.my.desktops.niri.enable;

        readOnly = true;
      };

      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}