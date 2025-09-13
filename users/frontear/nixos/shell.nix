{
  pkgs,
  ...
}:
{
  config = {
    programs.zsh.enable = true;

    users.users."frontear".shell = pkgs.zsh;
  };
}