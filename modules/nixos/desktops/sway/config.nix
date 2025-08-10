{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  config = lib.mkIf cfg.enable {
    my.services = {
      networkmanager.enable = true;
      pipewire.enable = true;
    };


    programs.uwsm = {
      enable = true;

      waylandCompositors.sway = {
        prettyName = "Sway";
        comment = "Sway compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/sway";
      };
    };


    my.persist.directories = [
      "/var/cache/tuigreet"
    ];

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = ''${lib.getExe pkgs.tuigreet} --greeting "Welcome to NixOS (${lib.versions.majorMinor lib.version})!" --time --remember --asterisks'';
      };
    };


    programs.sway = {
      enable = true;
      package = cfg.package;

      extraPackages = [];

      wrapperFeatures = {
        base = false;
        gtk = true;
      };
    };
  };
}
