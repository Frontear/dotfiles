{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;

  attrs = {
    my.audio.pipewire.enable = lib.mkDefault true;

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
    enable = lib.mkEnableOption "sway";

    default = lib.mkEnableOption "make default";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.default (lib.mkMerge [
      ({
        assertions = [
          {
            assertion = !config.my.desktops.plasma.default;
            message = "Sway and Plasma cannot both be default.";
          }
        ];
      })
      (lib.mkIf (config.specialisation != {}) attrs)
    ]))
    (lib.mkIf (!cfg.default) {
      specialisation.sway.configuration = attrs;
    })
  ]);
}
