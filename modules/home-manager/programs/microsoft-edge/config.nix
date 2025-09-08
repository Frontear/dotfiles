{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.microsoft-edge;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = "~/.config/${lib.getName cfg.package}";
        unique = false;
      }
      {
        path = "~/.cache/${lib.getName cfg.package}";
        unique = true;
      }
    ];

    home.packages = [
      cfg.package
    ];
  };
}
