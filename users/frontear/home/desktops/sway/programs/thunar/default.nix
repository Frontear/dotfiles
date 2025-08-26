{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;

  icon = "${config.gtk.iconTheme.package}/share/icons/${config.gtk.iconTheme.name}/24x24/apps/org.xfce.thunar.svg";
in {
  config = lib.mkIf cfg.enable {
    my.programs = {
      thunar.enable = true;
    };

    programs.waybar = {
      settings.bottom = {
        modules-center = lib.mkOrder 2 [
          "image#file_manager"
        ];

        "image#file_manager" = {
          path = "${icon}";
          size = 28;
          on-click = "uwsm app thunar.desktop";
          tooltip = false;
        };
      };
    };
  };
}
