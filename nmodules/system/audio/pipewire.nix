{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkForce mkIf;

  cfg = config.my.system.audio;
in {
  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = mkForce false;
    hardware.alsa.enablePersistence = mkForce false;

    security.rtkit.enable = true;

    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.jack.enable = true;
    services.pipewire.wireplumber.enable = true;
  };
}