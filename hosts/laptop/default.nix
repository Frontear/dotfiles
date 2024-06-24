{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    ../common
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.dell-inspiron-14-5420
    inputs.nixos-hardware.nixosModules.common-cpu-intel # pulls common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    inputs.home-manager.nixosModules.home-manager

    outputs.nixosModules.default
  ];

  frontear = {
    programs = {
      desktops.plasma.enable = true;
      direnv.enable = true;
      editors.neovim.enable = true;
      git.enable = true;
      gpg.enable = true;
      zsh.enable = true;
    };
    system = {
      boot.enable = true;
      swap.enable = true;
      network.enable = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  impermanence = {
    enable = true;

    system.directories = [ "/var/lib/systemd/backlight" "/var/lib/mysql" ];

    user.directories = [ "Documents" ];
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

  users.extraUsers.frontear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialHashedPassword =
      "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
  };

  # Everything else (for now)

  # TODO: possible to put in a devshell?
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
  };
}
