{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default
  ];

  # Nix required
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

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

  environment.systemPackages = with pkgs; [
    gnumake
    neovim
  ];

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
