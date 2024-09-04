{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf mkMerge;

  attrs = {
    my.system.audio.pipewire.enable = mkDefault true;

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd sway";
      };
    };

    programs.sway = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/commit/ff498279120074a4d9fdbbb7d18f7cebe57a7c9a
      package = (pkgs.swayfx.override (prev: {
        swayfx-unwrapped = prev.swayfx-unwrapped.override (prev: {
          scenefx = prev.scenefx.overrideAttrs (prevAttrs: {
            depsBuildBuild = (prevAttrs.depsBuildBuild or []) ++ [ prev.pkg-config ];
            nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [ prev.wayland-scanner ];
          });
        });
      }));

      extraPackages = with pkgs; [
        foot
      ];
    };
  };
in {
  options.my.system.desktops.sway = {
    enable = mkEnableOption "sway";

    default = mkEnableOption "make default";
  };

  config = mkIf config.my.system.desktops.sway.enable (mkMerge [
    (mkIf config.my.system.desktops.sway.default (mkMerge [
      ({
        assertions = [
          {
            assertion = !config.my.system.desktops.cosmic.default;
            message = "Sway and Cosmic cannot both be default.";
          }
          {
            assertion = !config.my.system.desktops.plasma.default;
            message = "Sway and Plasma cannot both be default.";
          }
        ];
      })
      (mkIf (config.specialisation != {}) attrs)
    ]))
    (mkIf (!config.my.system.desktops.sway.default) {
      specialisation.sway.configuration = attrs;
    })
  ]);
}
