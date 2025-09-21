{
  osConfig,
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.my.desktops.niri.enable;
      message = "Please enable my.desktops.niri in your NixOS configuration";
    }];


    xdg.configFile."niri/config.kdl".source = cfg.config;
  };
}