{
  pkgs,
  ...
}:
{
  config = {
    # Install yt-dlp to save my videos
    environment.systemPackages = with pkgs; [ yt-dlp ];

    # Enable some WSL sanities
    wsl = {
      enable = true;
      nativeSystemd = true;
      useWindowsDriver = true;
    };

    # Use nix-ld for the VSCode server
    programs.nix-ld.enable = true;
  };
}
