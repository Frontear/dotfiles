{
  lib,
  ...
}:
{
  options = {
    my.network.networkmanager = {
      enable = lib.mkEnableOption "networkmanager";
    };
  };
}
