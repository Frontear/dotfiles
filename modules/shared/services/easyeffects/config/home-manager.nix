{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.easyeffects;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      # TODO: needed?
      path = "~/.config/easyeffects";
      unique = true;
    }];

    services.easyeffects = {
      enable = true;

      extraPresets = cfg.presets;
    };
  };
}