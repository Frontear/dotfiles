{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.boot;
in {
  config = mkIf cfg.enable {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.editor = false;
  };
}