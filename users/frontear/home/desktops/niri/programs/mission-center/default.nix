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
    home.packages = with pkgs; [
      mission-center
    ];

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 3 [
          "cffi/process_monitor"
        ];


        "cffi/process_monitor" = {
          module_path = pkgs.frontear.waybar-icon.lib;

          icon-name = "io.missioncenter.MissionCenter";
          on-click = "app2unit -- io.missioncenter.MissionCenter.desktop";
          tooltip = false;
        };
      };
    };
  };
}