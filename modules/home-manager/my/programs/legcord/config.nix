{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.legcord;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/legcord";
      unique = true;
    }];

    home.packages = [
      cfg.package
    ];
  };
}