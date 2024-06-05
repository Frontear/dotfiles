{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.system.boot;
in {
  options.frontear.system.boot = {
    enable = mkEnableOption "opinionated boot module.";
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;

        memtest86.enable = true;
      };

      timeout = 0;
    };
  };
}