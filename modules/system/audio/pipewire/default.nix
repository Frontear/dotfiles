{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce mkIf;
in {
  options.my.system.audio.pipewire.enable = mkEnableOption "pipewire";

  config = mkIf config.my.system.audio.pipewire.enable {
    # Explicitly disable pulseaudio and alsa
    hardware.pulseaudio.enable = mkForce false;
    hardware.alsa.enablePersistence = false; # https://github.com/NixOS/nixpkgs/issues/330606

    # PipeWire benefits from having realtime priority
    security.rtkit.enable = true;

    # Enable all pipewire related backends, for maximum compatibility
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}