{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.desktops.sway = {
      enable = lib.mkEnableOption "sway" // {
        default = osConfig.my.desktops.sway.enable;
      };

      config = lib.mkOption {
        type = with lib.types; path;
      };
    };
  };
}