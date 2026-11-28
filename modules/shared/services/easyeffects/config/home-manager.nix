{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.services.easyeffects;
  fmt = pkgs.formats.json {};

  mkAutoload = type: cfg.autoload.${type}
    |> lib.map (x: {
      name = "easyeffects/autoload/${type}/${x.device}:${x.device-profile}.json";
      value = {
        source = fmt.generate "${x.device}:${x.device-profile}.json" x;
      };
    });
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        # TODO: needed?
        path = "~/.config/easyeffects";
        unique = true;
      }
      {
        # TODO: this is only being done because of the autoload folder.
        # There are some things I don't want to declare, but still want to have.
        # Is this reasonable..?
        path = "~/.local/share/easyeffects";
        unique = true;
      }
    ];

    xdg.dataFile = lib.listToAttrs (
      mkAutoload "input" ++ mkAutoload "output"
    );

    services.easyeffects = {
      enable = true;

      # By default, load the "nothing" preset. Preset loading should be setup
      # via autoload.
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