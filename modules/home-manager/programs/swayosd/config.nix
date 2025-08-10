{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.swayosd;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];


    systemd.user.services.swayosd = {
      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe' cfg.package "swayosd-server"} -s ${cfg.style}";

        Restart = "on-failure";
        Slice = "background.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
