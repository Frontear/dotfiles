{ inputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    ../programs/git
    ../programs/gpg
    ../programs/microsoft-edge
    ../programs/neovim
    ../programs/vscode
    ../programs/zsh
  ];

  # Nix required
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

  # Necessary for booting the system
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager"
    ];

    users.frontear = {
      directories = [
        "Documents"
      ];
    };
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

  networking = {
    networkmanager.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;

    xserver = {
      enable = true;

      displayManager.sddm.enable = true;

      libinput.enable = true;
    };
  };

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

    users.frontear.home.stateVersion = "24.05";
  };

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
