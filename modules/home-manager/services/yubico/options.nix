{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.services.yubico = {
      enable = lib.mkEnableOption "yubico" // {
        default = osConfig.my.services.yubico.enable;
      };
    };
  };
}