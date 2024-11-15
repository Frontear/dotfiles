{
  config,
  ...
}:
{
  config = {
    # Disable TLP to prevent it from conflicting with
    # auto-cpufreq.
    services.tlp.enable = false;

    # Enable both auto-cpufreq and thermald.
    services = {
      auto-cpufreq.enable = true;
      thermald.enable = true;
    };

    # Use chrony as an NTP client that's better in
    # general for laptops, and has better power savings.
    services.chrony.enable = true;
    my.persist.directories = [
      config.services.chrony.directory
    ];
  };
}
