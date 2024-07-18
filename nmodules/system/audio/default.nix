{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.audio;
in {
  imports = lib.importsRecursive ./. (x: x != "default.nix");

  options.my.system.audio.enable = mkEnableOption "audio";

  config = mkIf cfg.enable {
    services.pipewire.enable = true;
  };
}