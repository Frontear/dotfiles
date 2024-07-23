{ nixos-wsl, ... }: ({ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    nixos-wsl.nixosModules.default
  ];

  my.system.nix.enable = true;

  frontear.programs.terminal.enable = true;

  my.users.frontear.programs.atool.enable = true;
  my.users.frontear.programs.neovim.enable = true;

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

  environment.systemPackages = with pkgs; [ yt-dlp ];
})
