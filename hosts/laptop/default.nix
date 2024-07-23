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

  my.users.frontear.programs.atool.enable = true;
  my.users.frontear.programs.neovim.enable = true;
  my.users.frontear.programs.vscode.enable = true;

  my.system.boot.enable = true;
  my.system.mounts.enable = true;
  my.system.network.enable = true;
  my.system.nix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  my.system.persist = {
    enable = true;
    directories = [ "/var/lib/systemd/backlight" ];
  };

  my.users.frontear.persist = {
    enable = true;
    directories = [
      "~/Documents"
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

  users.users."frontear".extraGroups = [ "networkmanager" "wheel" ];
  my.users."frontear".initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
})
