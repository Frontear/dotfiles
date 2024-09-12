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
    ({ system.stateVersion = "24.05"; })
    ({
      # Setup WSL values
      wsl.enable = true;
      wsl.nativeSystemd = true;
      wsl.useWindowsDriver = true;
    })
    ({
      # Use nix-ld for vscode server
      programs.nix-ld.enable = true;
      programs.nix-ld.package = pkgs.nix-ld-rs;
    })
    ({
      # Add yt-dlp to system packages
      environment.systemPackages = with pkgs; [ yt-dlp ];
    })
  ];
}
