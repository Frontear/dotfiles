{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.parsec;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.parsec";
      unique = true;
    }];

    home.packages = [
      cfg.package
    ];
  };
}