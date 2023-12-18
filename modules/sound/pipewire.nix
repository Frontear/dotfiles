{
    config,
    lib,
    ...
}:
let
    inherit (lib) mdDoc mkForce mkOption mkIf types;
in {
    options.sound.pipewire = mkOption {
        type = types.bool;
        description = mdDoc ''
        This enables the PipeWire audio server, alongside
        compatibility services with ALSA, JACK, and
        PulseAudio. Uses WirePlumber as the session
        manager.
        '';
    };

    config = mkIf config.sound.pipewire {
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            audio.enable = true;
            jack.enable = true;
            pulse.enable = true;
            wireplumber.enable = true;
        };

        sound.enable = mkForce false;
    };
}
