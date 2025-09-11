{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.legcord;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/legcord"
    ];

    home.packages = [
      cfg.package
    ];
  };
}