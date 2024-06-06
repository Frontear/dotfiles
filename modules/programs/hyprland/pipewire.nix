{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.hyprland;
in {
  config = mkIf cfg.enable {
    sound.enable = lib.mkForce false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}