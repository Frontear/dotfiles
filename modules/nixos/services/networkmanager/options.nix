{
  lib,
  ...
}:
{
  options = {
    my.services.networkmanager = {
      enable = lib.mkEnableOption "networkmanager";
    };
  };
}
