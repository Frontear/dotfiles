{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  my.users.frontear.programs = {
    atool.enable = true;
    armcord.enable = true;
    direnv.enable = true;
    eza.enable = true;
    git.enable = true;
    gpg.enable = true;
    libreoffice.enable = true;
    microsoft-edge.enable = true;
    neovim.enable = true;
    vscode.enable = true;
    zsh.enable = true;
  };

  my.system = {
    boot.enable = true;
    desktops.plasma.enable = true;
    mounts.enable = true;
    network.enable = true;
    nix.enable = true;
  };

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
}
