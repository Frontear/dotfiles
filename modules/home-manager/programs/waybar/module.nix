{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.waybar;

  bin = lib.getExe' cfg.package "waybar";
  conf = config.xdg.configFile."waybar/config".source;
  style = config.xdg.configFile."waybar/style.css".source;
in {
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      systemd.enable = true;
    };

    xdg.configFile = {
      "waybar/config".enable = lib.mkForce false;
      "waybar/style.css".enable = lib.mkForce false;
    };

    systemd.user.services.waybar = {
      Service = {
        ExecStart = lib.mkForce "${bin} -c ${conf} -s ${style}";

        Slice = "app.slice";
      };
    };
  };
}
