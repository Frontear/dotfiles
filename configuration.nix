{ config, lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "LAPTOP-3DT4F02";
    networkmanager.enable = true;
  };

  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  time.timeZone = "America/Toronto";

  services.xserver = {
    enable = true;

    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;

    libinput.enable = true;
  };

  users.users.frontear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "$y$j9T$oYpEIjpqe22y.WBZsVSeS0$90SjyotOGGTEttwCe/bmh/A01v/U3D78YXnSM6ukZl8";
  };

  environment.systemPackages = with pkgs; [
    git
    gnumake
    neovim
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.stateVersion = "24.05";

  # ---

  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager"
    ];

    users.frontear = {
      directories = [
        ".gnupg"

        "Documents"
      ];

      files = [
        ".gitconfig"
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
}
