{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkForce mkIf;

  cfg = config.frontear.system.sound;
in {
  options.frontear.system.sound = {
    enable = mkEnableOption "opinionated sound module";
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = mkForce false;
    sound.enable = mkForce false;

    security.rtkit.enable = true;

    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.jack.enable = true;
    services.pipewire.wireplumber.enable = true;
  };
}