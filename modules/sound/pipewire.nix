{
    lib,
    ...
}: {
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        audio.enable = true;
        jack.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
    };

    sound.enable = lib.mkForce false;
}
