{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    my.programs.element = {
      enable = true;
    };
  };
}