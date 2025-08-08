{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.dunst;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];


    dbus.packages = [
      cfg.package
    ];

    systemd.user.services.dunst = {
      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";

        ExecStart = "${lib.getExe cfg.package} -config ${cfg.config}";

        Restart = "on-failure";
        Slice = "background.slice";
      };
    };
  };
}
