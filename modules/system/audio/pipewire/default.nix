{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce mkIf mkMerge;
in {
  options.my.system.audio.pipewire.enable = mkEnableOption "pipewire";

  config = mkIf config.my.system.audio.pipewire.enable (mkMerge [
    {
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