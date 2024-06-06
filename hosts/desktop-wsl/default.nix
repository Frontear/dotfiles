{ inputs, outputs, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default

    outputs.programs.neovim
    outputs.programs.zsh
  ];

  frontear.programs = {
    direnv.enable = true;
    git.enable = true;
    gpg.enable = true;
  };

  wsl = {
    enable = true;
    defaultUser = "nixos";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ gnumake neovim yt-dlp ];
}
