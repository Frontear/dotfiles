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

      settings = lib.mkOption {
        type = with lib.types; lines;
      };
    };
  };
}