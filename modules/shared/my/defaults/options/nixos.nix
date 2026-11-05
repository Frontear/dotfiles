{
  lib,
  ...
}:
{
  options = {
    my.defaults = {
      enable = lib.mkDefaultEnableOption "defaults";
    };
  };
}