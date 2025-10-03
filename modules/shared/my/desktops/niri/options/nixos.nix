{
  lib,
  ...
}:
{
  options = {
    my.desktops.niri = {
      enable = lib.mkEnableOption "niri";
    };
  };
}