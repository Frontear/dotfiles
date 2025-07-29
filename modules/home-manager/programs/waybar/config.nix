{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.waybar;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];


    systemd.user.services.waybar = {
      Unit = {
        Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors";
        Documentation = "https://github.com/Alexays/Waybar/wiki/";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package} -c ${cfg.config} -s ${cfg.style}";
        ExecReload = "kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
