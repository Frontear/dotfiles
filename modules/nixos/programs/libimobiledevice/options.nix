{
  lib,
  ...
}:
{
  options = {
    my.programs.libimobiledevice = {
      enable = lib.mkDefaultEnableOption "libimobiledevice";
    };
  };
}