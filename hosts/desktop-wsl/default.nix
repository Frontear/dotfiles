{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  environment.systemPackages = with pkgs; [
    yt-dlp
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  wsl = {
    enable = true;
    nativeSystemd = true;
    useWindowsDriver = true;
  };
}
