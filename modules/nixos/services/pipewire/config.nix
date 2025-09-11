{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.pipewire;
in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Kill PulseAudio and ALSA stuff
      services.pulseaudio.enable = lib.mkForce false;
      hardware.alsa.enablePersistence = false; # https://github.com/NixOS/nixpkgs/issues/330606
    }
    {
      # Enable realtime kit and PipeWire. Additionally,
      # enable all PipeWire backends for improved compat.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;

        alsa.enable = true;
        alsa.support32Bit = lib.mkDefault true; # TODO: ?
        pulse.enable = true;
        jack.enable = true;
      };
    }
    {
      # https://www.reddit.com/r/linux/comments/1em8biv/psa_pipewire_has_been_halving_your_battery_life/
      services.pipewire.wireplumber.extraConfig."10-disable-camera" = {
        "wireplumber.profiles" = {
          "main" = {
            "monitor.libcamera" = "disabled";
          };
        };
      };
    }
  ]);
}