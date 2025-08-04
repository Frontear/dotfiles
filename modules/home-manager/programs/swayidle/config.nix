{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.swayidle;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];


    systemd.user.services.swayidle = {
      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package} -C ${cfg.config} -w";

        Restart = "on-failure";
        Slice = "background.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
