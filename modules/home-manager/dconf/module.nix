{
  config,
  lib,
  ...
}:
let
  cfg = config.dconf;
in {
  config = lib.mkIf cfg.enable {
    # Not every dconf setting can be declared, like locations.
    # Privacy concerns and other reasons.
    my.persist.directories = [{
      path = "~/.config/dconf";
      unique = true;
    }];
  };
}