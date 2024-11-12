{
  config,
  ...
}:
{
  config = {
    services.chrony.enable = true;
    my.persist.directories = [
      config.services.chrony.directory
    ];
  };
}
