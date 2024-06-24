{ nixos-wsl, ... }: ({ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    nixos-wsl.nixosModules.default
  ];

  frontear.programs.terminal.enable = true;

  wsl = {
    enable = true;
    defaultUser = "frontear";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];
})