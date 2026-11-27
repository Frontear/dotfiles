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

      # By default, load the "nothing" preset. Preset loading should be setup
      # via autoload, and unfortunately this is imperative.
      #
      # TODO: make autoload partially declarative?
      preset = "nothing";

      extraPresets = {
        nothing = lib.genAttrs [ "input" "output" ] (_: {
          blocklist = [];
          plugins_order = [];
        });
      } // cfg.presets;
    };
  };
}