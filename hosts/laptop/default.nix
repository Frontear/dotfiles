{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  my.system = {
    boot.systemd-boot.enable = true;
    mounts.swap.enable = true;
    network.networkmanager.enable = true;

    persist = {
      enable = true;
      directories = [ "/var/lib/systemd/backlight" ];
    };
  };

  my.users.frontear = {
    persist.enable = true;

    programs = {
      armcord.enable = true;
      direnv.enable = true;
      eza.enable = true;
      gpg.enable = true;
      microsoft-edge.enable = true;
      vscode.enable = true;
      zsh.enable = true;
    };
  };

  my.system.desktops = {
    plasma.enable = true;
    plasma.default = true;

    sway.enable = true;
  };

  my.users.frontear.persist.directories = [
    "~/.config"
    "~/.local"
  ];

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
