{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    services.pipewire.enable = true;


    my.persist.directories = [{
      path = "/var/cache/tuigreet";
      unique = true;
    }];

    services.greetd = {
      enable = true;

      settings.default_session = {
        command = ''${lib.getExe pkgs.tuigreet} --greeting "Welcome to NixOS (${lib.versions.majorMinor lib.version})!" --time --remember --asterisks'';
      };
    };


    environment.sessionVariables = {
      "NIXOS_OZONE_WL" = 1;
    };

    programs.niri = {
      enable = true;
    };
  };
}