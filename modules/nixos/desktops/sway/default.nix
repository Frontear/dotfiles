{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  options.my.desktops.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {
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
}
