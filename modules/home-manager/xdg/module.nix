{
  config,
  lib,
  ...
}:
let
  dirs = [
    "~/Desktop"
    "~/Documents"
    "~/Downloads"
    "~/Music"
    "~/Pictures"
    "~/Public"
    "~/Templates"
    "~/Videos"
  ];
in {
  config = {
    xdg.enable = lib.mkDefault true;

    my.persist.directories = lib.mkIf config.xdg.enable (map (path: {
      inherit path;
      unique = false;
    }) dirs);
  };
}