{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default
    outputs.nixosModules.main-user

    outputs.programs.direnv
    outputs.programs.git
    outputs.programs.gpg
    outputs.programs.neovim
    outputs.programs.zsh
  ];

  wsl = {
    enable = true;
    defaultUser = "nixos";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  main-user = {
    name = "nixos";
  };

  environment.systemPackages = with pkgs; [
    gnumake
    neovim
    yt-dlp
  ];
}
