{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.desktops.niri = {
      enable = lib.mkEnableOption "niri" // {
        default = osConfig.my.desktops.niri.enable;
      };

      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}