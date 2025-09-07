{
  osConfig,
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.gnome;
in {
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.my.desktops.gnome.enable;
      message = "Please enable my.desktops.gnome in your NixOS configuration";
    }];


    # TODO: determine what actually needs to be kept and what doesn't
    my.persist.directories = [
      {
        path = "~/.cache";
        unique = true;
      }
      {
        path = "~/.config";
        unique = true;
      }
      {
        path = "~/.local";
        unique = true;
      }
    ];
  };
}
