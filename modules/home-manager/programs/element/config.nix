{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.element;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/Element";
      unique = true;
    }];

    home.packages = [
      cfg.package
    ];
  };
}