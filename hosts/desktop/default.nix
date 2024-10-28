{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  config = lib.mkMerge [
    {
      environment.systemPackages = [ pkgs.yt-dlp ];
    }
    {
      # WSL
      wsl.enable = true;
      wsl.nativeSystemd = true;
      wsl.useWindowsDriver = true;

      # VSCode Server
      programs.nix-ld.enable = true;
    }
    { system.stateVersion = "24.05"; }
  ];
}
