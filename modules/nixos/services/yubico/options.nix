{
  lib,
  ...
}:
{
  options = {
    my.services.yubico = {
      enable = lib.mkDefaultEnableOption "yubico";
    };
  };
}
