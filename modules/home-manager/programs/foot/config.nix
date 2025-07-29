{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.foot;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];


    systemd.user = {
      services.foot-server = {
        Service = {
          ExecStart = "${lib.getExe cfg.package} --server=3";
          UnsetEnvironment = [ "LISTEN_PID" "LISTEN_FDS" "LISTEN_FDNAMES" ];
          NonBlocking = true;
        };

        Unit = {
          Requires = [ "%N.socket" ];
          Description = "Foot terminal server mode";
          Documentation = "man:foot(1)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      # TODO: is having a socket worth the first-time launch delay?
      sockets.foot-server = {
        Socket = {
          ListenStream = "%t/foot.sock";
        };

        Unit = {
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}

