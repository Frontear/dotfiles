{ pkgs, ... }:
let
  username = "frontear";
  password = "$y$j9T$su48WZAkv959zLnMoZv/40$oKdLivhKud81hzdnif6IuK8gdMDP9fkSJdYgRg2Zjb0";
in
{
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    promptInit =
    ''
    autoload -U promptinit && promptinit && prompt redhat && setopt prompt_sp
    '';
    shellInit =
    ''
    touch ~/.zshrc
    ''; # suppress the stupid warning
    syntaxHighlighting.enable = true;
  };

  users.mutableUsers = false;
  users.users.root.initialPassword = "${password}";
  users.extraUsers.${username} = {
    packages = with pkgs; [
      neovim
    ];
    extraGroups = [ "wheel" "networkmanager" ];
    isNormalUser = true;
    initialHashedPassword = "${password}";
    shell = pkgs.zsh;
  };
}
