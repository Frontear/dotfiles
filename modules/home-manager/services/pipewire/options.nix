{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.services.pipewire = {
      enable = lib.mkEnableOption "pipewire" // {
        default = osConfig.my.services.pipewire.enable;
      };
    };
  };
}