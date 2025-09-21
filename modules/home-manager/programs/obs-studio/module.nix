{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.obs-studio;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/obs-studio";
      unique = true;
    }];
  };
}