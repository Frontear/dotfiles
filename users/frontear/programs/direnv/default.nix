{
  config,
  ...
}:
{
  my.programs.direnv = {
    enable = true;

    config = {
      whitelist.prefix = [ "${config.home.homeDirectory}/Documents" ];
    };
  };
}