{
  config,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    ({
      xdg.enable = lib.mkDefault true;
      my.persist.directories = lib.mkIf config.xdg.enable [
        "~/Desktop"
        "~/Documents"
        "~/Downloads"
        "~/Music"
        "~/Pictures"
        "~/Public"
        "~/Templates"
        "~/Videos"
      ];
    })
  ];
}