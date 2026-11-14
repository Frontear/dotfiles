{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.easyeffects;
in {
  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;

      extraPresets = cfg.presets;
    };
  };
}