{
  self,
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
        modules-center = lib.mkOrder 3 [
          "cffi/process_monitor"
        ];


        "cffi/process_monitor" = {
          module_path = self.packages.waybar-icon.lib;

          icon-name = "io.missioncenter.MissionCenter";
          on-click = "uwsm app io.missioncenter.MissionCenter.desktop";
          tooltip = false;
        };
      };
    };
  };
}
