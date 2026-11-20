{
  config,
  lib,
  ...
}:
let
  cfg = config.my.defaults;

  mkUseOption = _: lib.mkOption {
    default = cfg.enable;

    type = with lib.types; bool;
  };
in {
  options = {
    my.defaults = {
      enable = lib.mkDefaultEnableOption "defaults";

      useKernel = mkUseOption {};
    };
  };
}