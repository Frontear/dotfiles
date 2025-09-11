{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;

  colors = config.lib.stylix.colors.withHashtag;
in {
  config = lib.mkIf cfg.enable {
    stylix.targets.dunst.enable = true;

    services.dunst = {
      enable = true;

      settings = {
        global = {
          offset = "(4, 4)";
          frame_width = 2;
          gap_size = 4;
          corner_radius = 4;
        };

        # Change some Stylix defaults
        urgency_low.frame_color = lib.mkForce colors.base0D;
        urgency_normal.frame_color = lib.mkForce colors.base09;
        urgency_critical.frame_color = lib.mkForce colors.base08;
      };
    };
  };
}