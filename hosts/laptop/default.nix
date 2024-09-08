{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  my.persist = {
    enable = true;
    directories = [ "/var/lib/systemd/backlight" ];
  };

  my = {
    boot.systemd-boot.enable = true;
    mounts.swap.enable = true;
    network.networkmanager.enable = true;

    desktops = {
      plasma.enable = true;
      plasma.default = true;

      sway.enable = true;
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
