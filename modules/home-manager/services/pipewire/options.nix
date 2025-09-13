{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.services.pipewire = {
      enable = lib.mkEnableOption "pipewire" // {
        default = osConfig.services.pipewire.enable;
      };
    };
  };
}