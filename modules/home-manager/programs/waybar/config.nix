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
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package} -c ${cfg.config} -s ${cfg.style}";

        Restart = "on-failure";
        Slice = "app.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
