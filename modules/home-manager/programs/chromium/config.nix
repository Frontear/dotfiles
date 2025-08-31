{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.chromium;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/${lib.getName cfg.package}"
      "~/.cache/${lib.getName cfg.package}"
    ];

    home.packages = [
      cfg.package
    ];
  };
}
