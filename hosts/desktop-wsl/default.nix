{ inputs, outputs, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    outputs.nixosModules.default

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default
  ];

  frontear.programs.terminal.enable = true;

  wsl = {
    enable = true;
    defaultUser = "frontear";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];
}
