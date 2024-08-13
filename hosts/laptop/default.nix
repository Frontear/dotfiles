{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  documentation.dev.enable = true;

  system.stateVersion = "24.05";

  my.users.frontear = {
    extraGroups = [ "networkmanager" "wheel" ];
    initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
    persist.enable = true;

    programs = {
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
  };

  my.system = {
    audio.pipewire.enable = true;
    boot.systemd-boot.enable = true;
    desktops.plasma.enable = true;
    mounts.swap.enable = true;
    network.networkmanager.enable = true;

    persist = {
      enable = true;
      directories = [ "/var/lib/systemd/backlight" ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  time.timeZone = "America/Toronto";

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
}
