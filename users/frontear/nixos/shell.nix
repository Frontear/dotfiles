{
  config,
  ...
}:
{
  config = {
    my.programs.zsh.enable = true;

    users.users."frontear".shell = config.my.programs.zsh.package;
  };
}