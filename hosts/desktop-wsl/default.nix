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
    outputs.programs.vscode # ? maybe not
    outputs.programs.zsh
  ];

  programs.git = {
    enable = true;

    config = {
      commit.gpgSign = true;
      init.defaultBranch = "main";
      tag.gpgSign = true;
      user.email = "perm-iterate-0b@icloud.com";
      user.name = "Ali Rizvi";
      user.signingKey = "BCB5CEFDE22282F5";
    };
  };

  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
  };

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
