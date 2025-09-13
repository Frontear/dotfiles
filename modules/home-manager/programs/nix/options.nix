{
  osConfig,
  lib,
  ...
}:
{
  options = {
    my.programs.nix = {
      enable = lib.mkEnableOption "nix" // {
        default = osConfig.nix.enable;
      };
    };
  };
}