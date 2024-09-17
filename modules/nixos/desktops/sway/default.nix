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

    my.persist.directories = [
      { path = "/var/cache/tuigreet"; user = "greeter"; group = "greeter"; mode = "755"; }
    ];

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = ''${lib.getExe pkgs.greetd.tuigreet} --cmd sway --greeting "Welcome to NixOS (${lib.versions.majorMinor lib.version})!" --time --remember --asterisks'';
      };
    };

    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
    };

    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
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
