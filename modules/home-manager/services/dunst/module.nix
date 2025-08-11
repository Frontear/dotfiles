{
  config,
  lib,
  ...
}:
let
  cfg = config.services.dunst;

  bin = lib.getExe' cfg.package "dunst";
  conf = config.xdg.configFile."dunst/dunstrc".source;
in {
  config = lib.mkIf cfg.enable {
    services.dunst = {
      settings.global = lib.mkIf (config.stylix.enable && config.stylix.targets.gtk.enable) {

        # This is an outdated method of resolving the icons, home-manager
        # still uses it but we want the newer `icon_theme` method.
        icon_path = lib.mkForce "";

        enable_recursive_icon_lookup = true;
        icon_theme = config.gtk.iconTheme.name;
      };
    };

    xdg.configFile."dunst/dunstrc".enable = lib.mkForce false;

    systemd.user.services.dunst = {
      Service = {
        ExecStart = lib.mkForce "${bin} -config ${conf}";

        Slice = "background.slice";
      };
    };
  };
}
