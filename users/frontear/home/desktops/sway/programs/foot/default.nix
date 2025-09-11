{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  config = lib.mkIf cfg.enable {
    stylix.targets.foot.enable = true;

    programs.foot = {
      enable = true;

      settings = {
        cursor = {
          style = "beam";
          unfocused-style = "none";
          blink = "yes";
          beam-thickness = "1.0";
        };

        key-bindings = {
          search-start = "Control+f";
        };

        search-bindings = {
          find-prev = "Up";
          find-next = "Down";
        };
      };
    };
  };
}