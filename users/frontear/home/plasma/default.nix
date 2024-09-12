{
  osConfig,
  lib,
  ...
}:
{
  my.persist.directories = lib.mkIf (osConfig.my.desktops.plasma.enable) [
    "~/.config"
    "~/.local"
  ];
}
