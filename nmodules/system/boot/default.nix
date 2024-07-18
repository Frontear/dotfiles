{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.boot;
in {
  imports = lib.importsRecursive ./. (x: x != "default.nix");

  options.my.system.boot.enable = mkEnableOption "boot";

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
  };
}