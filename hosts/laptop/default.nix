{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager

    outputs.nixosModules.impermanence

    outputs.programs.direnv
    outputs.programs.git
    outputs.programs.gpg
    outputs.programs.hyprland
    outputs.programs.microsoft-edge
    outputs.programs.neovim
    outputs.programs.network-manager
    outputs.programs.systemd-boot
    outputs.programs.vscode
    outputs.programs.zsh
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

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  impermanence = {
    enable = true;

    user.directories = [
      "Documents"
    ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=2G" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "noatime" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/store";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  users.users.frontear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
  };

  # Everything else (for now)

  environment.systemPackages = with pkgs; [
    # C
    gcc
    gdb
    gnumake
    man-pages
    valgrind

    # Nix
    nil
    nixpkgs-fmt

    # Rust
    cargo
    rustc
    rustfmt
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.frontear = {
      home.stateVersion = "24.05";
    };
  };

  documentation = {
    dev.enable = true;

    man.generateCaches = true;

    nixos.includeAllModules = true;
  };
}
