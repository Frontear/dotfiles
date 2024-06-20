{ inputs, outputs, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    outputs.nixosModules.default

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default
  ];

  frontear.programs = {
    direnv.enable = true;
    git.enable = true;
    gpg.enable = true;
    editors.neovim.enable = true;
    zsh.enable = true;
  };

  wsl = {
    enable = true;
    defaultUser = "frontear";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];
}
