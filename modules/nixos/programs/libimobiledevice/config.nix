{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.libimobiledevice;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ifuse
      idevicerestore
      libimobiledevice
    ];

    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };
}