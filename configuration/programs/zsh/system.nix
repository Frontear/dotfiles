{ pkgs, ... }: {
  users.users.frontear.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
  };
}
