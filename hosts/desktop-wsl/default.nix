{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  documentation.dev.enable = true;

  system.stateVersion = "24.05";

  my.users.frontear.programs = {
    atool.enable = true;
    direnv.enable = true;
    eza.enable = true;
    git.enable = true;
    gpg.enable = true;
    neovim.enable = true;
    zsh.enable = true;
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  wsl = {
    enable = true;
    defaultUser = "frontear";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];
}
