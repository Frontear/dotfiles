{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.foot;

  bin = lib.getExe' cfg.package "foot";
  conf = config.xdg.configFile."foot/foot.ini".source;
in {
  config = lib.mkIf cfg.enable {
    programs.foot = {
      server.enable = true;
    };

    xdg.configFile."foot/foot.ini".enable = lib.mkForce false;

    systemd.user.services.foot = {
      Service = {
        ExecStart = lib.mkForce "${bin} -c ${conf} --server";

        Slice = "app.slice";
      };
    };
  };
}

