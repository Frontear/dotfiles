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

  home-manager.users.frontear.home.packages = [
    pkgs.yt-dlp
  ];

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
}
