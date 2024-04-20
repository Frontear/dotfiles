{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager

    outputs.nixosModules.impermanence
    outputs.nixosModules.main-user

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

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  impermanence = {
    enable = true;

    system.directories = [
      "/var/lib/systemd/backlight"
      "/var/lib/mysql"
    ];

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

  main-user = {
    name = "frontear";

    extraConfig = {
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
    };
  };

  # Everything else (for now)

  environment.systemPackages = with pkgs; [
    # Nix
    nil
    nixpkgs-fmt

    # Rust
    cargo
    rustc
    rustfmt
  ];

  # TODO: possible to put in a devshell?
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
  };
}
