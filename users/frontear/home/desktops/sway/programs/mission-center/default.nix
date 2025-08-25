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
    home.packages = with pkgs; [
      mission-center
    ];

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkAfter [
          "custom/icon#process_monitor"
        ];


        "custom/icon#process_monitor" = {
          format = "";
          on-click = "uwsm app missioncenter";
          tooltip = false;
        };
      };
    };
  };
}
