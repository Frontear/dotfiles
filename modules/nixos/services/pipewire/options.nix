{
  lib,
  ...
}:
{
  options = {
    my.services.pipewire = {
      enable = lib.mkEnableOption "pipewire";
    };
  };
}