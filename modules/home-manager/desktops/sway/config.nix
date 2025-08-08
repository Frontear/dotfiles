{
  osConfig,
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.my.desktops.sway.enable;
      message = "Please enable my.desktops.sway in your NixOS configuration";
    }];


    home.sessionVariables.NIXOS_OZONE_WL = "1";
    systemd.user.sessionVariables.NIXOS_OZONE_WL = "1";


    xdg.configFile."sway/config".source = cfg.config;
  };
}
