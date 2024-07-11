{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.boot.loader.systemd-boot.enable {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.editor = false;
  };
}