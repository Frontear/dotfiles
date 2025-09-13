{
  config,
  lib,
  ...
}:
let
  cfg = config.services.pipewire;
in {
  config = lib.mkIf cfg.enable {
    # Kill ALSA and PulseAudio related things.
    hardware.alsa.enablePersistence = lib.mkForce false; # https://github.com/NixOS/nixpkgs/issues/330606
    services.pulseaudio.enable = lib.mkForce false;

    # Needed by PipeWire
    security.rtkit.enable = true;

    services.pipewire = {
      # Compatibility services in PipeWire.
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;

      # https://www.reddit.com/r/linux/comments/1em8biv/psa_pipewire_has_been_halving_your_battery_life/
      wireplumber.extraConfig."10-disable-camera" = {
        "wireplumber.profiles" = {
          "main" = {
            "monitor.libcamera" = "disabled";
          };
        };
      };
    };
  };
}