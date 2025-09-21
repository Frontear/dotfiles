{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.desktops.niri = {
      enable = lib.mkEnableOption "niri";
    };
  };
}