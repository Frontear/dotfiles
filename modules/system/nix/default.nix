{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.nix;
in {
  imports = lib.importsRecursive ./. (x: x != "default.nix");

  options.my.system.nix.enable = mkEnableOption "nix";

  config = mkIf cfg.enable {
    nix.enable = true;
  };
}