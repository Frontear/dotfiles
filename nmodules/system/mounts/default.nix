{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.mounts;
in {
  imports = lib.importsRecursive ./. (x: x != "default.nix");

  options.my.system.mounts.enable = mkEnableOption "mounts";

  config = mkIf cfg.enable {
    zramSwap.enable = true;
  };
}