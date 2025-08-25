{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;

  icon = "${config.gtk.iconTheme.package}/share/icons/${config.gtk.iconTheme.name}/24x24/apps/io.missioncenter.MissionCenter.svg";
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mission-center
    ];

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkAfter [
          "image#process_monitor"
        ];


        "image#process_monitor" = {
          path = "${icon}";
          size = 28;
          on-click = "uwsm app missioncenter";
          tooltip = false;
        };
      };
    };
  };
}
