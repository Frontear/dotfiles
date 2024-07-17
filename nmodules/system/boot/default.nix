{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.boot;
in {
  imports = [
    ./boot-loader.nix
    ./silent-boot.nix
  ];

  options.my.system.boot.enable = mkEnableOption "boot";

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
  };
}