{
  lib,
  ...
}:
{
  options = {
    my.defaults = {
      enable = lib.mkEnableOption "defaults";
    };
  };
}