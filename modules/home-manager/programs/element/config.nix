{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.element;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/Element"
    ];

    home.packages = [
      cfg.package
    ];
  };
}
