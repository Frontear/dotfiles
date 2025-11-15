{
  config,
  ...
}:
{
  config = {
    # Use chrony as an NTP client that's better in
    # general for laptops, and has better power savings.
    services.chrony.enable = true;
    my.persist.directories = [
      config.services.chrony.directory
    ];
  };
}