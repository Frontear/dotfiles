{ ... }: {
  # System
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    audio.enable = true;
    jack.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };
}