{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkForce mkIf mkMerge;
in {
    options = {
        sound.pipewire = mkEnableOption ''
        enables the PipeWire audio server alongside compatibility services
        for ALSA, JACK, and PulseAudio, with WirePlumber as session manager.
        '';
    };

    config = mkMerge [
        (mkIf config.sound.pipewire {
            # TODO: find a way to reduce repetition here
            services.pipewire = {
                enable = true;
                alsa.enable = true;
                audio.enable = true;
                jack.enable = true;
                pulse.enable = true;
                wireplumber.enable = true;
            };

            # only provides ALSA setup, but PipeWire manages that.
            sound.enable = mkForce false;
        })
    ];
}
