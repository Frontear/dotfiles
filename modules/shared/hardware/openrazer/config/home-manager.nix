{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.hardware.openrazer;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      polychromatic
    ];
  };
}