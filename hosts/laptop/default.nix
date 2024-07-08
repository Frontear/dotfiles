{ nixos-hardware, ... }: ({ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    nixos-hardware.nixosModules.dell-inspiron-14-5420
    nixos-hardware.nixosModules.common-cpu-intel # pulls common-gpu-intel
    nixos-hardware.nixosModules.common-hidpi
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  frontear.programs.desktops.plasma.enable = true;
  frontear.programs.graphical.enable = true;
  frontear.programs.terminal.enable = true;

  frontear.system.boot.enable = true;
  frontear.system.swap.enable = true;
  frontear.system.network.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  impermanence = {
    enable = true;

    system.directories = [ "/var/lib/systemd/backlight" ];

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
})
