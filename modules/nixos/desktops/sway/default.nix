{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf mkMerge;

  attrs = {
    my.audio.pipewire.enable = mkDefault true;

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd sway";
      };
    };

    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
    };
  };
in {
  options.my.desktops.sway = {
    enable = mkEnableOption "sway";

    default = mkEnableOption "make default";
  };

  config = mkIf config.my.desktops.sway.enable (mkMerge [
    (mkIf config.my.desktops.sway.default (mkMerge [
      ({
        assertions = [
          {
            assertion = !config.my.desktops.plasma.default;
            message = "Sway and Plasma cannot both be default.";
          }
        ];
      })
      (mkIf (config.specialisation != {}) attrs)
    ]))
    (mkIf (!config.my.desktops.sway.default) {
      specialisation.sway.configuration = attrs;
    })
  ]);
}
